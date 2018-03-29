/* profile.rex -- EXTERNAL PROCEDURE that executes as a command
 TSO PROFILE command emulator
 
 example usage, in a REXX program:
  'profile prefix('userid')'
  'profile noprefix'
  
 this program sets a "pool" value that relates
 a "prefix" with a file prefix
 
 the value is set in the ALLOC.POOL selector pool
 
 command line arguments are parsed by the related ARGPARSE.REX program
 
 only the PREFIX and NOPREFIX keywords are processed 
 
 see also:
   alloc.rex
   free.rex
   listalc.rex
   listdsi.rex
*/

  cmdArgs = arg(1)
 
  'newstack'
  
  errorText = argparse( cmdArgs )
  
  if errorText <> '' then do
    say errorText
    exit 12
    end
    
  prefix = ''
    
  do argNo=1 for queued()
  
    PULL qline 1 keyword keyValue /* uppercase text */
    
    if pos( left( qline, 1 ), "'""" ) > 0 , /* quoted value */
     | words( qline ) = 1 then do /* unquoted value */
      if keyword = 'NOPREFIX' then
        prefix = '>NOPREFIX<'
      iterate
      end
      
    if abbrev( keyword, 'PRE', 3 ) then do
      
      if length( keyValue ) = 0 then do
        call lineout !, 'PROFILE: PREFIX value is empty.'
        exit 12
        end
      
      if length( keyValue ) > 7 then do
        call lineout !, 'PROFILE: length of PREFIX must be between 1 and 7 characters.'
        call lineout !, '  Value (length:' || (length(keyValue)'):' keyValue
        exit 12
        end
        
      prefix = strip( keyValue, 'T', '.' )
      end /* keyword PREFIX */
  
    end argNo
  
  'delstack'
  
  if prefix = '' then do
    call lineout !, 'PROFILE: PREFIX value is absent.'
    exit 12
    end
    
  call value '>PREFIX<', copies( prefix, prefix <> '>NOPREFIX<' ), 'ALLOC.POOL'
   
  exit 0
    
    
