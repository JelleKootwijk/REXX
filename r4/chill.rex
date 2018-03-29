/* chill.rex
 this program converts a REXX source program to a 'chilled' program,
 which is unreadable. the chilled program is executable by 'r4' or 'roo',
 as though the original source file had been referenced.

 the chilled programs are created in the .\ice subdirectory. the chilled
 programs have the same name and extension as the original file, with
 '_ice' added before the extension. for example, if the original program
 is named
   myCoolProgram.rex
 the chilled program will be in the .\ice subdirectory with the following name:
   myCoolProgram_ice.rex

 corresponding 'iceSource' files are created in the .\iceSource subdirectory,
 with file names formatted as:
   source_YYMMDD_HHMMSS.rex
 'iceSource' files are created with the read-only attribute.
 you should BACKUP iceSource files on alternate media .. i.e. CD-ROM

 the 'chill.rex' program keeps a log of all requests in file 'chill.log'
 in the active working directory when chill.rex is started. when you
 need to find which 'iceSource' file corresponds with a specific '_ice'
 file you can locate the associated information in the chill.log file
 as follows:
  1. search for the name of the '_ice' file
  2. make sure the file date and time match the '_ice' files date&time
  3. the name of the corresponding source file is contained on the same line

 the related CHILL.EXE program performs the associated encryption

 there is no means of thawing a chilled program. 

 when chilled programs are executed, the SOURCELINE built-in function shows
    'sourceFile_ice.rex #N .. source is unavailable'
 or,
    'sourceFile_ice.rooProgram #N .. source is unavailable'
 or,
    'sourceFile_ice.roo #N .. source is unavailable'

 similar, output is displayed when errors occur, or during trace output.

 you can 'trace' the activities of chilled programs, by using the following
 environment variables, as described in the user's guide: r4.htm or roo.htm
   R4_EXECTRAC
   R4_TRACE_procedureName
   ROO_EXECTRAC
   ROO_TRACE_procedureName
   ROO_TRACE_CLASS_className
   ROO_TRACE_METHOD_className~methodName
*/

parse arg sourceFile 1 prefix '.' extension

if sourceFile = '' then
  call usagemsg

if \ stream( sourceFile, 'C', 'Exists' ) then
  call usagemsg 'Source file' sourceFile 'does NOT exist.'

if \ stream( 'ice', 'C', 'IsDir' ) then
  'mkdir ice'

if \ stream( 'iceSource', 'C', 'IsDir' ) then
  'mkdir iceSource'

iceFile = '.\ice\'prefix'_ice.'extension

sourceDateTime = substr( date( 'S' ), 3 )'_'space( translate( time(), ' ', ':' ), 0 )

iceSourceFile = '.\iceSource\'prefix'_'sourceDateTime'.'extension

if stream( iceFile, 'C', 'Exists' ) then do
  msgboxStyle = 4 + 32 + 256 /* Yes_No + iconQuestion + defaultButton2 */
  'MsgBox -CChill -S'msgboxStyle 'File' iceFile 'exists, do you want to replace it ?'
  if rc <> 6 then
    exit 1
  end

'chill' sourceFile iceFile

if rc = 0 then do
  'copy' sourceFile iceSourceFile
  'attrib +r' iceSourceFile
  logLine = substr( date( 'S' ), 3 ) time() 'Chilled' iceSourceFile fileDateTime( iceSourceFile ) '-->' iceFile fileDateTime( iceFile )
  call lineout 'chill.log', logLine
  call lineout !, logLine
  call lineout !, 'Please backup file' iceSourceFile 'to an alternate media; i.e. CD-ROM'
  end

exit 0

fileDateTime : procedure
  return 'FileDateTime(' word( stream( arg(1), 'C', 'fileinfo' ) , 1 ) ')'

usagemsg :
  call lineout !, arg( 1 )
  call lineout !, ''
  call lineout !, 'Usage:'
  call lineout !, '  r4 chill rexxSourceFile'
  call lineout !, ''
  call lineout !, 'Example:'
  call lineout !, '  r4 chill myCoolProgram.rex'
  call lineout !, ''
  call lineout !, 'Or:'
  call lineout !, '  r4 chill myCool.rooProgram'
  call lineout !, ''
  call lineout !, 'Or:'
  call lineout !, '  r4 chill myCoolClass.roo'
  call lineout !, ''
  call lineout !, 'Note: you can use roo instead of r4 to run chill.rex'
