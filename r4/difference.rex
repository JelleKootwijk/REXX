/* difference.rex
 determines set difference of two files
  given set A and set B
  computes the set A - B

 usage
  r4 DIFFERENCE setFile1 setFile2 [ > differenceSetFile ]
 
 or
  r4 DIFFERENCE - setFile2 [ < setFile1 ] [ > differenceSetFile ]

 or
  r4 DIFFERENCE setFile1 - [ < setFile2 ] [ > differenceSetFile ]


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

 r4 DIFFERENCE A B

 Computes:
  +---+
  | 2 |
  | 3 |
  | 5 |
  | 6 |
  | 7 |
  | 8 |
  +---+

 Whereas,
  r4 DIFFERENCE B A

 Computes:
  +----+
  | 16 |
  | 25 |
  | 36 |
  | 49 |
  | 64 |
  | 81 |
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

do lines( setFile2 )
  lin = linein( setFile2 )
  IN.lin = 1
  end

do lines( setFile1 )
  lin = linein( setFile1 )

  if \ IN.lin then
    call lineout tempFile, lin

  IN.lin = 1
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
  call lineout !, '  r4 DIFFERENCE setFile1 setFile2 [ > differenceSetFile ]'
  call lineout !, 'Or'
  call lineout !, '  r4 DIFFERENCE - setFile2 [ < setFile1 ] [ > differenceSetFile ]'
  call lineout !, 'Or'
  call lineout !, '  r4 DIFFERENCE setFile1 - [ < setFile2 ] [ > differenceSetFile ]'
  call lineout !, ''
  call lineout !, 'Where'
  call lineout !, '  setFile1 is a file of set member lines'
  call lineout !, '  setFile2 is another file of set member lines'
  call lineout !, ''
  call lineout !, "  A set file name of '-' indicates the default input stream."
  exit 1


