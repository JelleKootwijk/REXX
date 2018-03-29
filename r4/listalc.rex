/* listalc.rex -- EXTERNAL PROCEDURE that executes as a command
 TSO LISTALC command emulator
 
 example usage, in a REXX program:
  'listalc'
 
 command line arguments are parsed by the related ARGPARSE.REX program
 
 all keywords are ignored
 
 see also:
   alloc.rex
   listalc.rex
   listdsi.rex
   profile.rex
*/

  cmdArgs = arg(1)
 
/*    
  'newstack'
  
  errorText = argparse( cmdArgs )
  
  if errorText <> '' then do
    say errorText
    exit 12
    end
  ddname = ''
    
  do argNo=1 for queued()
  
    PULL qline 1 keyword keyValue /* uppercase text */
    
    if pos( left( qline, 1 ), "'""" ) > 0 , /* quoted value */
     | words( qline ) = 1 then do /* unquoted value */
      if keyword = 'ALL' then
        ddname = '>ALL<'
      iterate
      end
      
    if abbrev( keyword, 'F', 1 ) ,
     | abbrev( keyword, 'DD', 2 ) then do
      
      if length( keyValue ) = 0 then do
        call lineout !, 'FREE: DDNAME value is empty.'
        exit 12
        end
      
      if length( keyValue ) > 8 then do
        call lineout !, 'FREE: length of DDNAME must be between 1 and 8 characters.'
        call lineout !, '  Value (length:' || (length(keyValue)'):' keyValue
        exit 12
        end
        
      ddname = keyValue
      end /* keyword FI */
  
    end argNo
  
  'delstack'
*/    

  allFiles = value( '>ALL<', , 'ALLOC.POOL' )
  
  if allFiles = '' then
    say 'No files are allocated'
    
  else do
    say left( 'File', 8 ) 'Dataset'
  
    do while allFiles <> ''
      parse var allFiles ddname allFiles
      say left( ddname, 8 ) value( ddname, , 'ALLOC.POOL' )
      end
    
    end
   
  exit 0
    
    
