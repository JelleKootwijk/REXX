/* chgall.rex
 an EXAMPLE PROGRAM that uses the 'CHANGESTR' function

 usage:
  r4 chgall "/before/after" < infile > outfile

 or:
  r4 chgall "!before!after" < infile > outfile

 note:
  the first character of the argument string
  is an arbitrary character that is used to
  separate the string to replace, and the
  replacement string.
*/

parse value strip( arg( 1 ), 'B', '"' ) with sep +1 rest

if sep == '' then
  call usagemsg

if pos( sep, rest ) = 0 then
  call usagemsg 'The separator' sep 'was not found in:' rest
  
parse var rest before (sep) after

if length( before ) = 0 then
  call usagemsg 'The separator' sep 'was not found in:' rest

do lines()
  say changestr( linein(), before, after )
  end

exit 0

usagemsg : procedure

  if arg( 1 ) <> '' then
    call lineout !, arg( 1 )

  call lineout !, 'Usage:'
  call lineout !, '  r4 chgall "/before/after" < infile > outfile'
  call lineout !, ''
  call lineout !, 'Or:'
  call lineout !, '  r4 chgall "!before!after" < infile > outfile'

  exit 1
