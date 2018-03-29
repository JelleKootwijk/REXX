/* HtmlTableMiner.rex
 extracts text within an HTML file that are not within tags
 and are enclosed within <table> and </table>

 the output contains tabs between consecutive column values.

 <br> or <p> tags within column values are replaced by record separators ('1E'x).
 other options for replacing <br> and <p> tags are provided in comments
 below where the record separators are added.

 ..when the end of a table is encountered the program writes
 an empty line, a line containing three dots, and another
 empty line.

 usage
  r4 HtmlTableMiner < inFile.htm > outFile.txt
*/

inComment = 0

inTag = 0

textOut = ''

emit = 0

anotherCol = 0

tag = ''

cell = ''

end_marker_pending = 0

do lno=1 for lines()

  lin = linein()

  if lin = '' then iterate /* ignore empty lines */

/*
  call lineout !, lin
  trace ?I
*/

  htmlLine = lin

  if cell <> '' then do

    parse var lin before '<' tag '>'

	if before \== '' then
	  textOut = textOut' '
    end

  do inner=1 while lin <> ''
    
    if inComment then do
      if pos( '-->', lin ) > 0 then
        inComment = 0
      parse var lin . '-->' lin
      iterate inner
      end /* inComment */
    
    if inTag then do
      if pos( '>', lin ) > 0 then do
        parse var lin tag '>' lin
        inTag = 0
        end /* pos( '>', lin ) > 0 */
      else
        leave inner
      end /* inTag */

    if pos( '<', lin ) = 0 then do
      if emit > 0 then
        call AddSegment translate( lin, '  ', '0a0d'x )
      leave inner
      end /* pos( '<', lin ) = 0 */

    parse var lin before '<' lin

    if before \== '' then do
      if emit > 0 then
        call AddSegment translate( before, '  ', '0a0d'x )
      end

    if left( lin, 3 ) = '!--' then
      inComment = 1

    else if lin <> '' then do
           
      if pos( '>', lin ) = 0 then
        inTag = 1
        
      parse var lin origtag '>' lin

      tag = translate( word( origtag, 1 ) )

      if tag = 'TABLE' then do
        emit = emit + 1
        anotherCol = 0
        end /* tag = 'TABLE' */

      else if tag = '/TABLE' then do
        textOut = textOut || '0a0d'x || '...' || '0a0d'x
        emit = emit - 1
        anotherCol = 0
        end /* tag = '/TABLE' */

      else if wordpos( tag, 'TD TH' ) > 0 then do
        if anotherCol then do
          textOut = textOut || '09'x
          anotherCol = 0
          end /* anotherCol */
		cell = ''
        end /* wordpos( tag, 'TD TH' ) > 0 */

      else if wordpos( tag, '/TD /TH' ) > 0  then do
        anotherCol = 1
		cell = ''
		end

      else if tag = '/TR' then do
        anotherCol = 0
        say textOut
        textOut = ''
        end /* tag = '/TR' */

	  else if cell <> '' then
	    if wordpos( tag, 'BR P' ) > 0 then
		  call Add '1E'x /* this is a record separator character */

/* other options for replacing <br> and <p> tags in column values are shown below:

		  call Add '<'origTag'>'

		  call Add '0a0d'x

		  call Add ' '
*/
        
      end /* lin <> '' */
      
    end inner /* while lin <> '' */

  tag = ''

  end lno

say textOut

exit 0

AddSegment : procedure expose htmlLine textOut cell

  parse arg text
  
  if text = '' then
    return

  if right( textOut, 1 ) \== '' & left( text, 1 ) == ' ' then
    textOut = textOut' '

  text = strip( text )

  cell = cell || text

  do while text <> ''
  
    if pos( '&', text ) = 0 then do
      call Add text
      return
      end /* pos( '&', text ) = 0 */

    parse var text ,
    	before '&' rest

	posAnd = pos( '&', rest )

	posSemi = pos( ';', rest )

    if posSemi = 0 then do
      call Add before'&'rest
	  return
	  end

	if posAnd > 0 & posAnd < posSemi then do
      call Add before'&'
	  text = rest
	  iterate
	  end

    parse var text ,
    	before '&' ident ';' rest

    if ident = '' then do
      call Add text
      return
      end /* pos( '&', text ) = 0 */
	  
    if before <> '' then
      call Add before

    if ident = '' then do
      call lineout !, 'Poorly formed HTML text encountered. The invalid line is:'
      call lineout !, '  'htmlLine
      exit 2
      end /* ident = '' */

    text = rest

	addSpaceSeparator = 0

    select
      when ident = 'nbsp' then
        call Add ' '
      when ident = 'lt' then
        call Add '<'
      when ident = 'gt' then
        call Add '>'
      when ident = 'amp' then
        call Add '&'
      when ident = '#153' then
        call Add '(TM)'
      when ident = 'reg' then
        call Add '(R)'
      when ident = 'copy' then
        call Add '(C)'
      otherwise
        call Add '&'ident';'
      end /* select */
      
    end /* while text <> '' */
    
  return /* AddSegment */

Add : procedure expose textOut
  
  textOut = textOut || arg( 1 )

  return
