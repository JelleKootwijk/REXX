/* HtmlMiner.rex
 extracts text within an HTML file that are not within tags

 usage
  r4 HtmlMiner < inFile.htm > outFile.txt
*/

inComment = 0

inTag = 0

textOut = ''

tag = ''

do lno=1 for lines()
  lin = linein()

  if lin = '' then iterate /* ignore empty lines */

  /* trace ?r */

  htmlLine = lin

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
      call AddSegment lin
      leave inner
      end /* pos( '<', lin ) = 0 */

    parse var lin before '<' lin

    if before \== '' then
      call AddSegment before

    if left( lin, 3 ) = '!--' then
      inComment = 1

    else if lin <> '' then do
  	    
      if pos( '>', lin ) = 0 then
        inTag = 1

      parse var lin tag '>' lin
      tag = translate( tag )

      end /* lin <> '' */
      
    end inner

  if textOut <> '' then do
    say space( textOut, 1 )
    textOut = ''
    end /* textOut <> '' */

  tag = ''

  end lno

exit 0

AddSegment : procedure expose htmlLine textOut tag
  parse arg text
  
  if text = '' then
    return
  
  if pos( '&', text ) = 0 then do
    call Add text
    return
    end /* pos( '&', text ) = 0 */

  do while text <> ''

    if pos( '&', text ) = 0 then do
      call Add text
      return
      end /* pos( '&', text ) = 0 */

    parse var text before '&' ident ';' rest
	  
    if before <> '' then
      call Add before

    if ident = '' then do
      call lineout !, 'Poorly formed HTML text encountered. The invalid line is:'
      call lineout !, '  'htmlLine
      exit 2
      end /* ident = '' */

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
      when left(ident,1) = ' ' then do
        call Add '&'
        text = substr(ident,2)
        iterate
        end
      otherwise
        call Add '&'ident';'
      end /* select */

    text = rest
      
    end /* while text <> '' */

  return /* AddSegment */

Add : procedure expose textOut tag
  if wordpos( tag, '/U /S' ) = 0 & textOut <> '' & right( textOut, 1 ) <> ' ' then
    textOut = textOut' '
  textOut = textOut || arg( 1 )
  return
