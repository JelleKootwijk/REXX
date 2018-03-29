/* union.rex
 determines set union of two files

 usage
  r4 UNION setFile1 setFile2 [ > unionSetFile ]
 
 or
  r4 UNION - setFile2 [ < setFile1 ] [ > unionSetFile ]

 or
  r4 UNION setFile1 - [ < setFile2 ] [ > unionSetFile ]

 example

    A      B
  +---+  +----+
  | 1 |  |  1 |
  | 2 |  |  4 |
  | 3 |  |  9 |
  | 4 |  | 16 |
  | 5 |  | 25 | 
  | 6 |  | 36 |
  | 7 |  | 49 |
  | 8 |  | 64 |
  | 9 |  | 81 |
  +---+  +----+

 r4 UNION A B

 computes union:
  +----+
  |  1 |
  | 16 |
  |  2 |
  | 25 |
  |  3 |
  | 36 |
  |  4 |
  | 49 |
  |  5 |
  |  6 |
  | 64 |
  |  7 |
  |  8 |
  | 81 |
  |  9 |
  +----+
*/

args = arg( 1 )

if left( args, 1 ) = '"' then
  parse var args +1 setFile1 '"' args

else
  parse var args setFile1 args

if left( args, 1 ) = '"' then
  parse var args +1 setFile2 '"' args

else
  parse var args setFile2 args

if setFile2 = '' then
  signal usagemsg

if args <> '' then
  call usagemsg 'only 2 set file names are expected.'

if setFile1 = '-' then
  setFile1 = '' /* default input stream */

if setFile2 = '-' then
  setFile2 = '' /* default input stream */

tempFile = GenerateTempFileName()

IN. = 0

do lines( setFile1 )
  lin = linein( setFile1 )

  if \ IN.lin then
    call lineout tempFile, lin

  IN.lin = 1
  end

if setFile1 <> setFile2 then do
  do lines( setFile2 )
    lin = linein( setFile2 )

    if \ IN.lin then
      call lineout tempFile, lin

    IN.lin = 1
    end
  end

call lineout tempFile /* close */

'sort <' tempFile	/* output to default output stream ! */

erase tempFile

exit 0

GenerateTempFileName : procedure

  do until \ stream( tempFile, 'C', 'Exists' )
    tempFile = 'TMP_' || right( random( 1, 9999 ), '0', 4 )
	end

  return tempFile

usagemsg :
  if arg( 1 ) then do
    call lineout !, arg( 1 )
    call lineout !, ''
	end

  call lineout !, 'Usage'
  call lineout !, '  r4 UNION setFile1 setFile2 [ > unionSetFile ]'
  call lineout !, 'Or'
  call lineout !, '  r4 UNION - setFile2 [ < setFile1 ] [ > unionSetFile ]'
  call lineout !, 'Or'
  call lineout !, '  r4 UNION setFile1 - [ < setFile2 ] [ > unionSetFile ]'
  call lineout !, ''
  call lineout !, 'Where'
  call lineout !, '  setFile1 is a file of set member lines'
  call lineout !, '  setFile2 is another file of set member lines'
  call lineout !, ''
  call lineout !, "  A set file name of '-' indicates the default input stream."
  exit 1


