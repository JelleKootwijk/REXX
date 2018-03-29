/* FileDlg.rex
 this program is an example 

 this program communicates with FileDlg.EXE via the registry
*/

trace off /* ignore nonzero return codes */

tab = d2c( 9 )

/* prepare FileDlg request entries -- using the 'Test' subkey */

'set R4REGISTRYWRITE=Y'   /* enable registry writing */

call value 'HKLM\Software\Kilowatt Software\FileDlg\Test[Filter]', 'CSV Files (*.csv)|*.csv|All Files (*.*)|*.*||', 'Registry'

call value 'HKLM\Software\Kilowatt Software\FileDlg\Test[InitialPath]', '*.csv', 'Registry'

 /* existing file selection */

if translate( left( arg(1)'S', 1 ) ) = 'S' then do
  call value 'HKLM\Software\Kilowatt Software\FileDlg\Test[Title]', 'Select a file to read', 'Registry'
  call value 'HKLM\Software\Kilowatt Software\FileDlg\Test[Select]', 'Yes', 'Registry'
  call value 'HKLM\Software\Kilowatt Software\FileDlg\Test[Write]', 'No', 'Registry'
  end

 /* file creation or replacement */

else do
  call value 'HKLM\Software\Kilowatt Software\FileDlg\Test[Title]', 'Select output file', 'Registry'
  call value 'HKLM\Software\Kilowatt Software\FileDlg\Test[Select]', 'No', 'Registry'
  call value 'HKLM\Software\Kilowatt Software\FileDlg\Test[Write]', 'Yes', 'Registry'
  end

'FileDlg Test'	/* show FileDlg -- using the 'Test' subkey */

say rc

/* get FileDlg response */

if rc = 1 then do
  fileName = value( 'HKLM\Software\Kilowatt Software\FileDlg\Test[File]', , 'Registry' )
  'MsgBox' 'You selected file' DoubleSlash( fileName )
  end

exit 0

 /* procedure DoubleSlash
  * converts single backward slash characters to double backward slash characters
  */

DoubleSlash : procedure
  r = ''
  s = arg( 1 )
  do while s <> ''
    parse var s front '\' s
	r = r || front
	if s <> '' then
	  r = r'\\'
    end
  return r

