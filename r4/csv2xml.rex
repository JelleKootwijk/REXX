/* csv2xml.rex

 usage:
  r4 CSV2XML rootTag < infile.csv > outfile.xml

 description:
  the CSV2XML program converts a comma-separated value file (CSV) to a corresponding XML file

 assumptions:
  the 1st line of the CSV file contains column tags
  remaining lines contain column values

 remarks:

  1. the root tag is one word -- i.e. it cannot contain any spaces
  
  2. warnings are presented when the number of column values does not match the number of column tags

  3. extraneous column values are not emitted

  4. empty elements are prepared when there are insufficient column values

  5. an internal DTD is always generated

  6. when input CSV item values contain commas, the entire value is enclosed in double-quotes,
     and interior double-quotes must be paired

  7. the split() function that is implemented here is patterned after the JavaScript equivalent
     with two differences.

      a. the first value returned is indexed by 1 instead of zero

	  b. this implementation handles the complicated format that CSV values can have,
	     whereas the JavaScript split() function is more trivial.

  8. spaces in column names are replaced with underscores, to conform with XML requirements
*/

if arg(1) = '' | arg(1) = '/?' | translate( left( arg(1), 2 ) ) = '/H' then
  call usagemsg

parse arg rootTag rest

if rootTag = '' then
  call usagemsg "A 'root tag' is required !!!"

if rest <> '' then
  call usagemsg 'Within the argument only one word is expected -- the root tag.'

call lineout !, 'Reading input CSV file lines'

nLines = lines()

if nLines < 1 then
  call usagemsg 'The input CSV file is empty; or the input file is not redirected.'

firstLine = 1

do nLines
  inline = linein()

  /* the first input line defines field tags */

  if firstLine then do
    
    firstLine = 0

    nElements = split( inline, 'FIELDTAG.', 1 )

	/* prepare document heading */

	say '<?xml version="1.0" encoding="UTF-8"?>'
	say '<!--' rootTag 'document definition -->'
	say '<!DOCTYPE' rootTag

	/* now prepare internal data type definition */

	say '  ['
	say '    <!ELEMENT' rootTag '(listItem+)>'
	say '    <!ELEMENT listItem (' /* start list item definition */

	do nElement = 1 to nElements
	  if nElement > 1 then
	    call charout , ', ' /* field separator */
	  call charout , FIELDTAG.nElement
	  end
	say ')>' /* conclude list item definition */

	/* define list item field tags */
	
	do nElement = 1 to nElements
		say '    <!ELEMENT' FIELDTAG.nElement '(#PCDATA)>'
		end

	say '  ]>' /* conclude internal DTD */

	say '<'rootTag'>' /* start document body */

	end

  /* remaining input lines are composed of field item values */

  else do

	ITEM. = '' /* reset default item values */

    nItems = split( inline, 'ITEM.', 0 )

	/* show a warning if the #items does not match #fields */

	if nItems != nElements then do
	  call lineout !, 'Warning, line #'lno  'has' nItems 'comma separated fields ('nElements' fields are expected).',
	  call lineout !, "The  line's contents are:"
	  call lineout !, "  "inline
	  end

	say '  <listItem>'

	do nItem = 1 to nElements
	  call charout , '    <'FIELDTAG.nItem || copies( '/', ITEM.nItem = '' )'>'
	  say copies( ITEM.nItem'</'FIELDTAG.nItem'>', ITEM.nItem <> '' )
	  end

	say '    </listItem>'

	end

  end

say '</'rootTag'>' /* conclude document body */

exit 0

	/* procedure USAGEMSG
	 * show usage information, with optional error note
	 */

usagemsg : procedure
  if arg() then
    call lineout !, arg( 1 )
  call lineout !, '  r4 CSV2XML rootTag < infile.csv > outfile.xml'
  exit 99

	/* procedure SPLIT
	 * splits a comma-separated value line into its constituent fields
	 * the 'stem' parameter identifies a collection of compound variables to assign
	 *
	 * on return,
	 *  STEM.length -- is the number of compound variables assigned
	 *  STEM.1 -- is the first field value
	 *  STEM.2 -- is the second field value
	 *   .
	 *   . [etc]
	 *   .
	 *
	 * result:
	 *  STEM.length is returned
	 */

split :

  parse arg lin , stem, translateSpaces

  nFields = 0

  if lin = '' then
    nop

  /* the simplest CSV line format just separates fields with commas.
   * this implies the line has no double-quotes.
   */

  if pos( '"', lin ) = 0 then do /* simple case */
    do while lin <> ''
	  nFields = nFields + 1
	  comma_pos = pos( ',',lin )
	  parse var lin field ',' lin
	  if translateSpaces then
	    field = translate( field, '_', ' ' )
	  call value stem || nFields, field /* assign field */

	  if comma_pos > 0 & lin = '' then do
	    nFields = nFields + 1
	    call value stem || nFields, lin /* assign field */
	    leave
	    end

	  end
    end

  else do

    /* double-quotes bracket field values that contain commas.
     * if the field also contains a double-quote, then these are paired.
     */

    do while lin <> ''
	  nFields = nFields + 1
	  if left( lin, 1 ) <> '"' then
	    parse var lin field ',' lin   /* simple field */
	  else do
	    field = ''
        do while lin \== ''
  	      parse var lin . +1 segment '"' lin
  	      if left( lin, 1 ) = '"' then  /* double-quote */
		    field = field'"'segment
		  else do
		    field = field || segment
		    if left( lin, 1 ) = ',' then
		      lin = substr( lin, 2 )
		    else if lin <> '' then do
		      note = 'Line' lno 'is incorrectly formatted' || '0a'x ,
			    || 'The incorrect line is:' arg( 1 )
		      call usagemsg note
			  end
		    leave
		    end
  	      end
	    end

	  if translateSpaces then
	    field = translate( field, '_', ' ' )

      call value stem || nFields, field /* assign field */
      end

    end

  call value stem'LENGTH', nFields /* STEM.LENGTH => #fields */

  return nFields