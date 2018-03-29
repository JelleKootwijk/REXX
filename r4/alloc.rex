/* alloc.rex -- EXTERNAL PROCEDURE that executes as a command
 TSO ALLOC command emulator
 
 example usage, in a REXX program:
  'alloc' 'fi('ddname') da('filename') shr'
 
 example usage, at a console prompt:
  r4 alloc f(ddname) da(filename) shr
  
 this program creates a "pool" value that relates
 a "ddname" with a filename
 
 the allocation is set in the ALLOC.POOL selector pool
 
 this program is used with the EXECIO command emulator
 
 command line arguments are parsed by the related ARGPARSE.REX program
 
 only the FILE/DDNAME and DATASET/DSNAME keywords are processed 
 
 file names that look like qual.qual(member) are converted to: qual.qual\member
 
 special processing of file name extensions can be accomodated by setting
 the ALLOC_EXTS environment variable to a space delimited series of extensions.
 for example, if you perform:
  set ALLOC_EXTS=asm c pas cbl pli h cpp java
 then, a file name that looks like PDS.cbl(prog) is converted to:
  PDS\prog.cbl
  
 an implicit high-level qualifier can be established by using the
 related PROFILE PREFIX(hiqual) command, that is implemented in
 PROFILE.REX
 
 allocations can be freed by the FREE command, that is implemented
 in FREE.REX
 
 all allocations can be removed by the "FREE ALL" command
 
 You should do a "FREE ALL" command at the end of a console session,
 so that these do not linger for a subsequent console session
 
 see also:
   execio.rex
   free.rex
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
  
  filename = ''
    
  do argNo=1 for queued()
  
    PULL qline 1 keyword keyValue /* uppercase text */
    
    if pos( left( qline, 1 ), "'""" ) > 0 , /* quoted value */
     | words( qline ) = 1 then /* unquoted value */
      iterate /* ignore non-keyword arguments */
      
    if abbrev( keyword, 'F', 1 ) ,
     | abbrev( keyword, 'DD', 2 ) then do
      
      if length( keyValue ) = 0 then do
        call lineout !, 'ALLOCATE: DDNAME value is empty.'
        exit 12
        end
      
      if length( keyValue ) > 8 then do
        call lineout !, 'ALLOCATE: length of DDNAME must be between 1 and 8 characters.'
        call lineout !, '  Value (length:' || length(keyValue)'):' keyValue
        exit 12
        end
        
      ddname = keyValue
      end /* keyword FILE */
      
    else if abbrev( keyword, 'DA', 2 ) ,
     | abbrev( keyword, 'DS', 2 ) then do
      
      if length( keyValue ) = 0 then do
        call lineout !, 'ALLOCATE: DSNAME value is empty.'
        exit 12
        end
        
      /* add optional prefix to unquoted filenames */
      
      if pos( left( keyValue, 1 ), '"''' ) > 0 then
        keyValue = strip( keyValue, 'B', left( keyValue, 1 ) )
        
      else do
        prefix = value( '>PREFIX<', , 'ALLOC.POOL' )
        
        if prefix <> '' then
          keyValue = prefix'.'keyValue
        end
        
      /* convert PDS.ext(member) file name */
      
      if pos( '(', keyValue ) > 0 then do
      
        parse var keyValue pdsname '(' member ')' rest
        
        if length( member ) = 0 then do
          call lineout !, 'ALLOCATE: dataset member name is empty.'
          exit 12
          end
          
        if length( rest ) > 0 then do
          call lineout !, 'ALLOCATE: invalid dataset name.'
          call lineout !, '  Value (length:' || length(keyValue)'):' keyValue
          exit 12
          end
        
        
        extensions = translate( value( 'ALLOC_EXTS', '', 'system' ) )
        
        lastdot = lastpos( '.', pdsname )
        
        if lastdot > 0 then do
          parse var pdsname prefix =(lastDot) +1 ext
          
          if wordpos( ext, extensions ) > 0 then
            filename = prefix'\'member'.'ext
          else
            filename = pdsname'\'member
          end
          
        else        
          filename = pdsname'\'member
        end
      
      else
        filename = keyValue

      end /* keyword DA */
  
    end argNo
  
  'delstack'
  
  if ddname = '' then do
    call lineout !, 'ALLOCATE: FILE/DDNAME value is absent.'
    exit 12
    end
  
  if filename = '' then do
    call lineout !, 'ALLOCATE: DSNAME/DATASET value is absent.'
    exit 12
    end
    
  call value ddname, filename, 'ALLOC.POOL'
  
  /* remember all files that were allocated */
  
  allFiles = value( '>ALL<', , 'ALLOC.POOL' )
    
  namepos = wordpos( ddname, allFiles )
    
  if namepos = 0 then
    call value '>ALL<', strip( allFiles ddname, 'L' ), 'ALLOC.POOL'
   
  exit 0
    
    
