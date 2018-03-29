/* box.rex
 enclose input within box characters

 usage
  r4 box [lineLength] < infile > outfile

 the default lineLength is 78

 example
   the following was created by r4 box 62 <box.rex
   ( before the following lines were pasted here )

  +------------------------------------------------------------+
  |/* box.rex                                                  |
  | enclose input within box characters                        |
  |                                                            |
  | usage                                                      |
  |  r4 box [lineLength] < infile > outfile                    |
  |                                                            |
  | the default lineLength is 78                               |
  |*/                                                          |
  |                                                            |
  |if arg( 1 ) = '' then                                       |
  |  lineLength = 78                                           |
  |                                                            |
  |else if datatype( arg( 1 ), 'Whole' ) <> 1 then             |
  |  call usagemsg 'The line length must be a whole number'    |
  |                                                            |
  |else do                                                     |
  |  lineLength = arg( 1 )                                     |
  |  if lineLength < 3 then                                    |
  |    call usagemsg 'The line length must be greater than 2'  |
  |  end                                                       |
  |                                                            |
  |say '+' || copies( '-', lineLength - 2 ) || '+'             |
  |do lines()                                                  |
  |  say '|' || left( linein(), lineLength - 2 ) || '|'        |
  |  end                                                       |
  |say '+' || copies( '-', lineLength - 2 ) || '+'             |
  |                                                            |
  |exit 0                                                      |
  |                                                            |
  |usagemsg :                                                  |
  |  call lineout !, arg( 1 )                                  |
  |  call lineout !, ''                                        |
  |  call lineout !, 'Usage'                                   |
  |  call lineout !, ' r4 box [lineLength] < infile > outfile' |
  |  exit 1                                                    |
  +------------------------------------------------------------+
*/

if arg( 1 ) = '' then
  lineLength = 78
  
else if datatype( arg( 1 ), 'Whole' ) <> 1 then
  call usagemsg 'The line length must be a whole number'

else do
  lineLength = arg( 1 )
  if lineLength < 3 then
    call usagemsg 'The line length must be greater than 2'
  end

say '+' || copies( '-', lineLength - 2 ) || '+'
do lines()
  say '|' || left( linein(), lineLength - 2 ) || '|'
  end
say '+' || copies( '-', lineLength - 2 ) || '+'

exit 0

usagemsg :
  call lineout !, arg( 1 )
  call lineout !, ''
  call lineout !, 'Usage'
  call lineout !, ' r4 box [lineLength] < infile > outfile'
  exit 1
