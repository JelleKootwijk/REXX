/* DRIVES.REX
 usage: r4 DRIVES [ > outFile ]
*/

if arg(1) <> '' then
  signal usagemsg

ndrives = stream( "", 'c', 'drives' )

do i=1 to ndrives 
  pull file
  say file
  end

exit 0

usagemsg :
  call lineout !, 'Usage:'
  call lineout !, '  r4 drives [ > outFile ]'
  exit 1