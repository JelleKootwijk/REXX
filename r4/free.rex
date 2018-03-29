/* free.rex -- EXTERNAL PROCEDURE that executes as a command
 TSO FREE command emulator
 
 example usage, in a REXX program:
  'free' 'fi('ddname')'
 
 example usage, at a console prompt:
  r4 free f(ddname)
 
 or:
  r4 free all
  
 this program resets a "pool" value that relates
 a "ddname" with a filename
 
 allocation information is saved in the ALLOC.POOL selector pool
 
 all allocations are freed when the "ALL" argument is specified
 
 command line arguments are parsed by the related ARGPARSE.REX program
 
 only the FILE/DDNAME and ALL keywords are processed 
 
 see also:
   alloc.rex
   listalc.rex
   listdsi.rex
   profile.rex
*/

  cmdArgs = arg(1)
 
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
        call lineout !, '  Value (length:' || length(keyValue)'):' keyValue
        exit 12
        end
        
      ddname = keyValue
      end /* keyword FI */
  
    end argNo
  
  'delstack'
  
  if ddname = '' then do
    call lineout !, 'FREE: FILE/DDNAME value is absent.'
    exit 12
    end
    
  if ddname = '>ALL<' then do
    allFiles = value( '>ALL<', '', 'ALLOC.POOL' )
    
    do while allFiles <> ''
      parse var allFiles ddname allFiles
      call value ddname, '', 'ALLOC.POOL'
      end
    end
    
  else do
    
    call value ddname, '', 'ALLOC.POOL'
    
    allFiles = value( '>ALL<', , 'ALLOC.POOL' )
    
    namepos = wordpos( ddname, allFiles )
    
    if namepos > 0 then
      call value '>ALL', delword( allFiles, namepos ), 'ALLOC.POOL'
    end
   
  exit 0
    
    
