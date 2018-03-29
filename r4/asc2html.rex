/* asc2html.rex

 ASC2HTML is a program that converts marked up Ascii text to a HTML file

Usage:
 r4 asc2html [options] < infile > outfile.htm

 'infile' is an Ascii text file that is marked up using the legend shown below.

 'options' is one of:
  /?                => show usage message
  /Help                => show usage message (1st two characters suffice)
  /NumberHeadings        => number heading levels, i.e. 1.3.4.1

Example:
 r4 asc2html < r4.asc > r4.htm

Returns:
 0 => success
 non-0 => error (invalid option, or empty input file)

Note:
 The asc2html.rex program converted the r4.asc file to the r4.htm web page!

Legend:

 Input lines are marked up as follows:

    ch[1]    : main formatting trigger
    ch[2]    : an optional formatting trigger (used with '+' and '`' triggers only)
    rest    : text to format

 Main formatting trigger -- ch[1]:

    ; remarkLine -- ignored

    ' ' untriggered line

    < HTML text written as-is

    I ascFileName -- Imbed marked up ascFileName

    @ preformattedFileName -- imbed preformatted file -- Rexx program, etc.

    ~ Begin escaped section -- script, etc
    . End escaped section

    + HeadingText
    - ends a heading level

    a urlTarget anchorText

    A spotText anchorText

    b break [followed by optional text]

    c centeredText

    i imageSrc rest

    p paragraph break [followed by optional text]

    r horizontal return [followed by optional text]

    v singleLine <DIV> ... </div>

    D starts a definition list
    O starts an ordered list
    U starts an unordered list
    T starts a table
    x starts an indented box of arbitrary width
    X starts a box that is 80% as wide as the browser window
    / ends a list, or table, or box

    l ListItemText -or- tableItem^tableItem^...    /* table columns are delimited by carets */
                                                /* long table lines can be continued by a trailing ' +' */

    h tableHeader^tableHeader^...    /* table headers are delimited by carets */

    L BoldListItemText

    d DefinitionText

    t DefinitionTermText

    z => omit 'Last Updated ...' line at end

    ` commandLine -- writes output of command line
    `u commandLine -- writes output of command line, UNFORMATTED
*/

    /* process 'options' */

arg options +2 .

    /* process 'help requests' */

if either( options, '/H', '/?' ) then
  call usagemsg    /* and exit! */

    /* validate 'options' */

if options <> '' & options <> '/N' then
  call usagemsg "Unrecognized program option: " arg(1)

enumerateHeadings = ( '/N' = options )    /* set optional enumerateHeadings boolean */

    /* show message that indicates default input stream is being read
     * in case, a redirected input file is not provided
     */

call lineout !, "Asc2Html: reading input..."

    /* assert input file has lines to process */

if lines() = 0 then
  call usagemsg "The input file is empty"

    /* initialize controls */

heading = 0        /* heading depth */

level. = 0        /* active heading level for each depth */

listtype = ''    /* 1st character indicates active list or table type */

escaped = 0        /* escape section active boolean indicator */

topLine = 0     /* 1 => top line within box */

showLastUpdatedLine =  1  /* 1 => show 'Last Updated ...' line at end */

addTabLinks = pos( 'PRESENTATION', translate( stream( '', 'C', 'chdir' ) ) ) > 0

topOptions = strip( linein() )

do while right( topOptions, 2 ) = ' +'
  topOptions = substr( topOptions, 1, length( topOptions ) - 2 ) ,
       || strip( linein() )
  end

parse var topOptions title '^' metaKeywords '~' bodyOptions

    /* write HTML heading section
     *  the 1st input line is the HTML file's title
     */

say '<HTML>'
say '<HEAD>'
say '<TITLE>' strip( title ) '</TITLE>'
if metaKeywords <> '' then
  say '<META  name="keywords" content="'metaKeywords'">'
say '<link rel=stylesheet type="text/css" HREF="kwsw.css">'
say '</HEAD>'

if bodyOptions <> '' then
  say '<BODY' bodyOptions'>'
else
  say '<BODY background=backgrnd.gif bgcolor=LIGHTSTEELBLUE>'

call processLines ''

    /* write HTML conclusion section */
say '<p>'

if showLastUpdatedLine then 
  say '<p><center><i>Last updated on:' date()'</center><p>'

say '</BODY>'
say '</HTML>'

exit 0    /* exit with code 0 => success */

processLines : /* procedure EXPOSEALL ! */

    /* process input lines */

do lines( arg(1) )

  lin = linein( arg(1) )    /* get another input line */

    /* process escaped text
     *  escaped text is triggered by a line that begins with a tilde (~)
     *  it concludes with a line that begins with a period (.)
     *  all text between these two lines is written as-is
     */

  if escaped then do
    if left( lin, 1 ) = '.' & lin = '.' then
      escaped = 0        /* end of escaped text */

    else if lin = ';beginSyntax' | lin = ';endSyntax' then iterate
    
    else do
        
      if left( translate( lin ), 6 ) = '</PRE>' then
        escaped = 0 /* implicit escape conclusion ! */
    
      say lin            /* write text as-is */
      
      end

    end

  else if lin = '' then
    say '<p>'            /* empty lines indicate paragraph separation */

  else do

        /* other input lines are marked up as follows:
         *  ch[1]    : main formatting trigger
         *  ch[2]    : an optional formatting trigger (used with '+' heading trigger only)
         *  rest    :  text to format
         */

    parse var lin ch +1 +1 rest
    rest = strip( rest, 'T' )

        /* process line by main formatting trigger */

    select

      when ch = ' ' then                    /* untriggered line */
        say rest

      when ch = 'l' then do                    /* list, table, or box row */

        if pos( left( listtype, 1 ), 'TX' ) = 0 then /* HTML list item */
          say '<LI>'rest

        else if left( listtype, 1 ) = 'X' then do /* 'X' => box row */
          if topLine then
            say '&nbsp;'rest
          else
            say '<BR>&nbsp;'rest
          topLine = 0
          end

        else do                                /* 'T' => table row */

          /* table rows can be lengthy, so allow continuation with ' +' at end of stripped line */

          do while right( rest, 2 ) = ' +'
            rest = substr( rest, 1, length( rest ) - 2 ) ,
                   || '<br>'strip( linein( arg(1) ) ) /* an implicit <br> tag is also added */
            end

          say '<TR>'
          do i=1 while rest <> ''
            parse var rest segment '^' rest    /* table columns are delimited by carets */
            say '<TD' || copies( " valign=top", i=1 )'>'segment'</TD>'
            end
          say '</TR>'
          end
        end

      when ch = 'b' then                    /* break */
        say '<BR>'rest

      when ch = 'p' then                    /* paragraph break */
        say '<P>'rest

      when ch = '<' then do                    /* formatted HTML text line */
        upperLin = translate( lin )
        
        if left( upperLin, 5 ) = '<PRE>' then
          escaped = 1 * ( 0 = pos( '</PRE>', upperLin ) ) /* implicit escape ! */

        say lin
        end

      when ch = '/' then                    /* list, table, or box conclusion */
        if queued() > 0 then do
          listtype = substr( listtype, 2 )    /* reduce active lists or tables */
          parse pull qline                    /* get list or table conclusion line */
          say qline
          end

      when ch = '~' then                    /* begin escaped section */
        escaped = 1

      when ch = ';' then                    /* commented text */
        iterate

      when ch = '-' then do                    /* end of heading section */
        call value 'level.' || ( heading + 1 ), 0    /* next level is concluded */
        heading = heading - 1                        /* reduce heading depth */
        end

      when ch = '+' then do                    /* new heading level */

        ch2 = substr( lin, 2, 1 )            /* non-blank ch[2] => 1st word is a heading id */

        heading = heading + 1                /* increase heading level */
        
        level.heading = level.heading + 1    /* increase heading depth for this level */

        if ch2 = ' ' then                    /* identifier-less heading */
          text = '<H'heading'>'

        else do
          text = '<H'heading
          parse var rest id rest
          text = text 'ID="'id'">'            /* add heading identifier */
          end

		/* prefix the heading text with a link so that the heading can be a tab target !! */

        if addTabLinks then
          text = text '<a href="#"><small>&#8226;</small></a> ' 

            /* prepare optional heading numbers */

        if enumerateHeadings then do
          number = ''
          do i=heading to 1 by -1
            number = level.i || copies( '.'number, number <> '' )
            end
          text = text number rest
          end

        else
          text = text rest                    /* prepare numberless heading */

        say text '</H'heading'>'
        end
      
      when ch = 'r' then                    /* horizontal return */
        say '<HR>'rest
      
      when ch = 'L' then                    /* bold list item */
        say '<LI><b>'rest'</b>'
      
      when ch = 'd' then                    /* definition list item */
        say '<DD><b>'rest'</b>'
      
      when ch = 't' then                    /* definition list text */
        say '<DT>'rest

      when ch = 'i' then do                    /* image */
        parse var rest src rest
        say '<IMG SRC="'src'"' rest'>'
        end

      when ch = 'v' then                    /* division */
        say '<DIV>'rest'</DIV>'

      when ch = 'c' then                    /* centered text */
        say '<center>'rest'</center>'

      when ch = 'a' then do                    /* link */
        parse var rest file rest
        say '<A HREF="'file'">' rest '</A>'
        end
      
      when ch = 'A' then do                    /* anchor */
        parse var rest spot rest
        say '<A NAME="'spot'">' rest '</A>'
        end
      
      when ch = 'D' then do                    /* new definition list */
        say '<ul><DL' rest'>'
        push '</DL></ul>'
        end
      
      when ch = 'U' then do                    /* new unordered list */
          listtype = 'U'listtype
        say '<UL' rest'>'
        push '</UL>'
        end
      
      when ch = 'O' then do                    /* new ordered list */
        listtype = 'O'listtype
        say '<OL' rest'>'
        push '</OL>'
        end
      
      when ch = 'T' then do                    /* new table */
        listtype = 'T'listtype
        if rest <> '' then
          say '<ul><TABLE' rest'>'
        else
          say '<ul><TABLE border=1>'
        push '</TABLE></ul>'
        end
      
      when ch = 'x' then do                    /* new box */
        listtype = 'X'listtype
        if rest <> '' then
          say '<ul><TABLE border=1 cellspacing=5' rest'><TR><TD>'
        else
          say '<ul><TABLE border=1 cellspacing=5><TR><TD>'
        push '</TD></TR></TABLE></ul>'
        topLine = 1
        end
            
      when ch = 'X' then do                    /* new box */
        listtype = 'X'listtype
        if rest <> '' then
          say '<ul><TABLE border=1 cellspacing=5 width=80%' rest'><TR><TD>'
        else
          say '<ul><TABLE border=1 cellspacing=5 width=80%><TR><TD>'
        push '</TD></TR></TABLE></ul>'
        topLine = 1
        end

      when ch = 'h' then do                    /* table header row */
        say '<TR>'
        do while rest <> ''
          parse var rest segment '^' rest    /* table headers are delimited by carets */
          say '<TH>'segment'</TH>'
          end
        say '</TR>'
        end

      when ch = 'I' then do
        call lineout !, 'Imbedding' rest '...'
        call processLines rest              /* imbed fileName */
        end

      when ch = '@' then do
        heading = heading + 1                /* increase heading level */
        level.heading = level.heading + 1    /* increase heading depth for this level */

        call lineout !, 'Imbedding, preformatted:' rest '...'
        call imbedPreformattedLines rest              /* imbed fileName */

        call value 'level.' || ( heading + 1 ), 0    /* next level is concluded */
        heading = heading - 1                        /* reduce heading depth */
        end

      when ch = '`' then do /* backquote -- command output */
        formatted = translate( substr( lin, 2, 1 ) ) <> 'U'
        newstack
        rest '(stack'
        if queued() > 0 then do
          if formatted then
            say '<pre>'
          do queued()
            parse pull qline
            if formatted then
              call charout , '<br>'
            say qline
            end
          if formatted then
            say '</pre>'
          end
        delstack
        end

      when ch = 'z' then
        showLastUpdatedLine = 0
      
      otherwise
          say rest                            /* whatever */
      end
    end
  end

  if arg(1) <> '' then
    call lineout arg(1)               /* close the file */

  return /* processLines */

imbedPreformattedLines : /*procedure*/
  say '<hr width=20 align=left>'
  say '<a name='arg(1)'>'

  text = '<H'2'>' /* instead of 2, 'heading' could be specified */

  if enumerateHeadings then do
    number = ''
    do i=heading to 1 by -1
      number = level.i || copies( '.'number, number <> '' )
      end
    text = text number
    end

  if pos( '\', arg(1) ) > 0 then
    say text substr( arg(1), 1 + lastpos( '\', arg(1) ) ) || '</H'2'>' /* instead of 2, 'heading' could be specified */
  else
    say text arg(1) || '</H'2'>' /* instead of 2, 'heading' could be specified */

  say '<ul>'
  say '<pre>'
  do lines( arg(1) )
    lin = linein( arg(1) ) /* get another input line */
    parse var lin before ':' after
    if after <> '' & 1 = words( before ) then
      say '<b>'before'</b> :' after
    else
      say lin
    end
  say '</pre>'
  say '</ul>'
  call lineout arg(1) /* close the file ! */
  return


    /* EITHER procedure
     *  determines if 1st argument matches the 2nd or 3rd argument
     */

either : procedure
  parse arg term, choice1, choice2
  return term = choice1 | term = choice2

    /* USAGEMSG procedure
     *  shows optional note and usage information
     *  then always exits with a code of 1 => error
     */

usagemsg :

    /* show optional note */

  if arg(1) <> '' then
    call lineout !, arg(1)

  call lineout !, 'Usage:'

  call lineout !, '  R4 ASC2HTML [/NumberHeadings] < infile.asc > outfile.htm'

  exit 1