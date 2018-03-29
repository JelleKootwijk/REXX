/* CsvDef.rex
 this program defines a new comma-separated value (CSV) file

 this program communicates with TopHat.EXE via the registry

 a tab delimited request is received from registry value:
  HKLM\Software\Kilowatt Software\R4\CsvDef[Request]
*/

tab = d2c( 9 )

/* get TopHat request -- see CsvDef.TopHat */

request = value( 'HKLM\Software\Kilowatt Software\R4\CsvDef[Request]', , 'Registry' )

/* parse tab delimited request fields */

parse var request ,
  field.1 (tab) ,
  field.2 (tab) ,
  field.3 (tab) ,
  field.4 (tab) ,
  field.5 (tab) ,
  field.6 (tab) ,
  field.7 (tab) ,
  field.8 (tab) ,
  field.9 (tab) ,
  field.10 (tab) ,
  field.11 (tab) ,
  field.12 (tab) ,
  field.13 (tab) ,
  field.14 (tab) ,
  field.15 (tab) ,
  field.16 (tab) ,
  field.17 (tab) ,
  field.18 (tab) ,
  field.19 (tab) ,
  field.20 (tab) ,
  field.21 (tab) ,
  field.22 (tab) ,
  field.23 (tab) ,
  field.24 (tab) ,
  field.25 (tab) ,
  field.26 (tab) ,
  field.27 (tab) ,
  field.28 (tab) ,
  field.29 (tab) ,
  field.30 (tab) ,
  field.31 (tab) ,
  field.32 (tab)

nFields = 0

do i=1 to 32
  field.i = strip( field.i )
  if field.i = '-' then leave
  nFields = nFields + 1
  end

trace off /* ignore nonzero return codes from the Prompt and MsgBox programs */

if nFields = 0 then do
  msgboxStyle = 32 /* Ok + iconQuestion + defaultButton2 */
  'MsgBox -CCsvDef -S'msgboxStyle' No input fields were defined ?'
  exit 99
  end

noteText = 'What is the name of the new CSV file ?'

caption = 'Prompt -- enter CSV file name'

trace off /* ignore Cancel button error */

registryValue = 'CsvFileName'

'Prompt' registryValue || tab || noteText || tab || caption

if rc = 0 then do
  csvFileName = value( 'HKLM\Software\Kilowatt Software\Prompt[CsvFileName]', , 'Registry' )
  if pos( '.', csvFileName ) = 0 then
    csvFileName = csvFileName'.CSV'
  end

msgboxStyle = 1 + 32 + 256 /* Ok_Cancel + iconQuestion + defaultButton2 */

 /* prompt to determine if replacement of existing files is desired */

if stream( csvFileName, 'C', 'Exists' ) then do
  'MsgBox -CCsvDef -S'msgboxStyle' File' csvFileName 'already exists. Do you want to replace it ?'
  if rc <> 1 then
    exit 1 
  end

'erase' csvFileName

do i=1 to nFields
  call charout csvFileName , copies( ',', i > 1 ) || enquoteIfNecessary( field.i )
  end

call lineout csvFileName, '' /* terminate 1st line */

exit 0

 /* procedure enquoteIfNecessary
  *  the argument is returned as-is if it does not contain commas
  *
  *  otherwise, the argument is wrapped with double-quotes
  *  and, interior double-quotes are doubled
  */

enquoteIfNecessary : procedure

  if verify( arg( 1 ), ',"', 'M' ) = 0 then /* no commas or dquotes */
    return arg( 1 )
  
  if pos( '"', arg( 1 ) ) = 0 then
    return '"'arg( 1 )'"'
    
  r = '"'                   /* result -- has leading double-quote */

  s = arg( 1 )
  
  do while s <> ''
  
    if s = '"' then
      return r'"""'
    
    if left( s, 1 ) = '"' then do
      r = r'""' /* double interior double-quote */
      s = substr( s, 2 )
      iterate
      end
  
    parse var s front '"' rest
    
    r = r || front
    
    s = '"'rest
    
    end

  return r'"' /* trailing double-quote */



