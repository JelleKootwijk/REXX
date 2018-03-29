/* DIRS.REX
 usage: r4 DIRS [directoryPath | dirPattern] [ > outFile ]
*/

if arg(1) = '?' then
  signal usagemsg

if stream( arg(1), 'c', 'isdir' ) then do
  'cd' arg(1)
  nDirs = stream( '', 'c', 'dirs' )
  end

else
  nDirs = stream( arg(1), 'c', 'dirs' )

do i=1 for nDirs
  pull dir
  say dir
  end

exit 0

usagemsg :
  call lineout !, 'Usage:'
  call lineout !, '  r4 dirs [directoryPath | dirPattern] [ > outFile ]'
  exit 1
