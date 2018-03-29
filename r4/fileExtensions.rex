/* fileExtensions.rex
 determine file types that match an optional pattern, within the current directory
 or, within a subdirectory

 example usage:
  r4 fileExtensions | fsort

 or:
  r4 fileExtensions *.roo* | fsort

 or:
  r4 fileExtensions subdir\*.roo* | fsort
*/

arg pattern

if pattern = '' then
  pattern = '*.*'

else if stream( pattern, 'C', 'isDir' ) then
  pattern = pattern'\*.*'

seen. = 0

do stream( pattern, 'C', 'files' )

  pull filename'.'extension .

  if \ seen.extension then do
    say extension
    seen.extension = 1
    end

  end
