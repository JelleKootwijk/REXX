/* execio.rex -- EXTERNAL PROCEDURE that operates as a command
 TSO EXECIO command emulator
  
 syntax summary ('+' indicates continuation on next line):
 
  EXECIO {lines|*} DISKW ddname +
    [( [STEM stem.] [OPEN] [FINIS] [)]]
  
 or,
   
  EXECIO {lines|*} DISKR|DISKRU ddname [firstLine] +
    [( [FIFO|LIFO|STEM stem.] [OPEN] [FINIS] [SKIP] [)]]
  
 notes:
  
  1. file ddnames are allocated by the related ALLOC commmand that is
     implemented in ALLOC.REX
 
  2. if the allocated file name is '-',  then the default input or
     output stream is used.
     
  3. if the output file already exists lines are APPENDED
     to the end of the file. You need to explicitly erase
     the file before performing EXECIO, as in the example
     below.  
  
  
 return codes (RC):
  0  -- successful completion
  1  -- data truncated during DISKW operation .. never occurs
  2  -- end of file reached before the #lines was reached
  4  -- no lines read and a #lines were specified
  20 -- severe error .. a message was issued
   
 see also:
  alloc.rex
  free.rex
 
 example usage, in a REXX program:
 
  /* reverse lines in file */
  
  parse arg infile ' , ' outfile 
  
  if stream( outfile, 'C', 'Exists' ) then do
    call lineout !, 'File' outfile 'already exists.' ,
      'Do you want to erase it ? (Y|N)'
    if translate( left( linein( ! ), 1 ) ) <> 'Y' then do
      call lineout !, 'Exiting. File' outfile 'has not been changed.'
      exit 1
      end
    'erase' outfile
    end
 
  'alloc fi(INDD)  da('infile') shr'
  'alloc f(OUTDD) da('outfile') old'
 
  'execio * diskr INDD (LIFO OPEN FINIS'
 
  'execio * diskw OUTDD (OPEN FINIS' /* write queued lines to OUTDD */
 
  'free f(OUTDD)'
  'free fi(INDD)'
  
  'type' outfile
  
  exit 0
*/

  /* need to be able to ref/set caller stem variable values */

  procedure exposeall /* use the force ! */
  
  /* since A-L-L of the caller's variables are E-X-P-O-S-E-D
     variables in this program are prefixed by stem _EXECIO.
     
     otherwise, the caller's variables could be erroneously
     altered by this program
     
     the _EXECIO. variables are dropped at exit
   */
   
  signal on novalue
  
  ARG _execio._xio_args
  
  if _execio._xio_args = '' then
    call usageMsg 'No arguments specified.'

  /* initialize various 0|1 switches */ 
  
  parse value '0' with ,
    _execio._xio_allLines       1 ,
    _execio._xio_diskr          1 ,
    _execio._xio_diskw          1 ,
    _execio._xio_fifo           1 ,
    _execio._xio_finis          1 ,
    _execio._xio_firstLine      1 ,
    _execio._xio_lifo           1 ,
    _execio._xio_lineCount      1 ,
    _execio._xio_open           1 ,
    _execio._xio_skip           1 ,
    _execio._xio_stem           1
  
  parse var _execio._xio_args _execio._xio_lineCount _execio._xio_args
  
  if _execio._xio_lineCount = '*' then
    _execio._xio_allLines = 1
     
  else if \ datatype( _execio._xio_lineCount, 'W' ) then
    call usageMsg 'Line count argument:' _execio._xio_lineCount', must be '*' or numeric >= 0'
    
  else if _execio._xio_lineCount < 0 then 
    call usageMsg 'Line count argument:' _execio._xio_lineCount', must be '*' or numeric >= 0'

  parse var _execio._xio_args _execio._xio_verb _execio._xio_ddname _execio._xio_args
  
  if wordpos( _execio._xio_verb, 'DISKR DISKRU DISKW' ) = 0 then
    call usageMsg 'Operation:' _execio._xio_verb', must be DISKR, DISKRU, or DISKW'
    
  _execio._xio_diskr = ( _execio._xio_verb <> 'DISKW' )
    
  _execio._xio_diskw = ( _execio._xio_verb = 'DISKW' )
  
  if _execio._xio_ddname = '' then
    call usageMsg 'DDNAME argument is absent'
    
  _execio._xio_filename = value( _execio._xio_ddname, , 'ALLOC.POOL' )
  
  if _execio._xio_filename = '' then
    call usageMsg 'DDNAME' _execio._xio_ddname' is not allocated'
    
  if _execio._xio_filename = '-' then /* '-' => default stream */
    _execio._xio_filename = ''
    
  else if _execio._xio_diskr = 1 ,
        & stream( _execio._xio_filename, 'C', 'Exists' ) = 0 then
    call usageMsg 'DDNAME' _execio._xio_ddname' FILE' _execio._xio_filename 'does not exist for DISKR'
    
  if _execio._xio_diskr = 1 ,
   & datatype( word( _execio._xio_args, 1 ), 'W' ) = 1 then do
   
    parse var _execio._xio_args _execio._xio_firstLine _execio._xio_args
   
    if _execio._xio_firstLine < 0 then
      call usageMsg 'First line to read:' _execio._xio_firstLine 'is less than zero.'
    end
    
  if _execio._xio_args = '' then
    signal value '_'verb
    
  if left( _execio._xio_args, 1 ) <> '(' then
    call usageMsg 'Left parenthesis expected instead of:' _execio._xio_args
    
  _execio._xio_args = strip( substr( _execio._xio_args, 2 ), 'L' ) /* skip the '(' */
  
  do _execio._xio_optNo=1 while _execio._xio_args <> ''
  
    if left( _execio._xio_args, 1 ) = ')' then do
      if substr( _execio._xio_args, 2 ) <> '' then
        call usageMsg "No value expected after ')' in:" _execio._xio_args 
      leave _execio._xio_optNo 
      end
      
    if word( _execio._xio_args, 1 ) = 'STEM' then do
      
      if _execio._xio_fifo | _execio._xio_lifo | _execio._xio_stem then
        call usageMsg 'FIFO LIFO or STEM already specified before:' _execio._xio_args
      
      parse var _execio._xio_args . _execio._xio_stemName _execio._xio_args
      
      if pos( '.', _execio._xio_stemName ) <> length( _execio._xio_stemName ) then
        call usageMsg 'Stem name' _execio._xio_stemName 'does not end with a period'
      
      if symbol( _execio._xio_stemName ) = 'BAD' then
        call usageMsg 'Stem name' _execio._xio_stemName 'is invalid'
      
      _execio._xio_stem = 1
      end
      
    else if wordpos( word( _execio._xio_args, 1 ), 'LIFO FIFO' ) > 0 then do
      
      if _execio._xio_fifo | _execio._xio_lifo | _execio._xio_stem then
        call usageMsg 'FIFO LIFO or STEM already specified before:' _execio._xio_args
        
      if _execio._xio_diskw then
        call usageMsg word( _execio._xio_args, 1 ) 'is invalid during a DISKW operation'
        
      _execio._xio_fifo = ( word( _execio._xio_args, 1 ) = 'FIFO' ) 
        
      _execio._xio_lifo = ( word( _execio._xio_args, 1 ) = 'LIFO' ) 
      
      parse var _execio._xio_args . _execio._xio_args
      
      end
      
    else if wordpos( word( _execio._xio_args, 1 ), 'OPEN FINIS SKIP' ) = 0 then
      call usageMsg 'OPEN FINIS or SKIP expected instead of:' _execio._xio_args
      
    else do
      parse var _execio._xio_args _execio._xio_wd1 _execio._xio_args
      _execio._xio_open  = ( _execio._xio_wd1 = 'OPEN' ) 
      _execio._xio_finis = ( _execio._xio_wd1 = 'FINIS' ) 
      _execio._xio_skip  = ( _execio._xio_wd1 = 'SKIP' ) 
      end
      
    end _execio._xio_optNo 
    
  signal on NOTREADY
    
  signal value '_'_execio._xio_verb
  
_diskr : _diskru :

  if _execio._xio_firstLine > 0 then
    call linein _execio._xio_filename, _execio._xio_firstLine, 0
    
  _execio._xio_linesRead = 0
    
  do _execio._xio_lno=1 while lines( _execio._xio_filename ) > 0
  
    if _execio._xio_allLines = 0 ,
     & _execio._xio_lno > _execio._xio_lineCount then
      leave _execio._xio_lno
  
    if _execio._xio_skip then
      _execio._xio_bitBucket = linein( _execio._xio_filename )
      
    else do /* add a line that was read */
      _execio._xio_linesRead = _execio._xio_linesRead + 1
      
      if _execio._xio_lifo then
        push linein( _execio._xio_filename )
        
      else if _execio._xio_fifo then
        queue linein( _execio._xio_filename )
        
      else /* stem */
        call value _execio._xio_stemName || _execio._xio_lno, linein( _execio._xio_filename )

      end /* add a line that was read */
      
    end _execio._xio_lno
    
  if _execio._xio_stem then 
    call value _execio._xio_stemName'0', _execio._xio_linesRead
      
  if _execio._xio_finis then
    call lineout _execio._xio_filename
    
  if _execio._xio_allLines = 0 ,
   & _execio._xio_linesRead = 0 ,
   & _execio._xio_lineCount > 0 then do
    drop _execio.
    exit 4
    end
    
  if _execio._xio_allLines = 0 ,
   & _execio._xio_linesRead < _execio._xio_lineCount then do
    drop _execio.
    exit 2
    end
  
  drop _execio.
  exit 0
  
_diskw :

  if _execio._xio_stem then do
  
    _execio._xio_nStemLines = value( _execio._xio_stemName'0' )
    
    if datatype( _execio._xio_nStemLines, 'W' ) = 0 then
      call usageMsg 'Value of' _execio._xio_stemName'0 is not numeric'
    
    end

  do _execio._xio_lno=1 /* forever */
  
    if _execio._xio_allLines = 0 ,
     & _execio._xio_lno > _execio._xio_lineCount then
      leave _execio._xio_lno
      
    if _execio._xio_stem = 0 then do
    
      if queued() = 0 then
        leave _execio._xio_lno
        
      parse pull _execio._xio_lin
      
      end
      
    else do /* stem */
      
      if _execio._xio_lno > _execio._xio_nStemLines then
        leave _execio._xio_lno
      
      _execio._xio_lin = value( _execio._xio_stemName || _execio._xio_lno )
      end
      
    call lineout _execio._xio_filename, _execio._xio_lin
  
    end _execio._xio_lno 
      
  if _execio._xio_finis then
    call lineout _execio._xio_filename
    
  exit 0
  
notready :
novalue :

  signal off novalue

  call lineout !, 'EXECIO' _execio._xio_filename condition('I') 'error,' condition('D')'.'
  call lineout !, ' SOURCE('sigl')' sourceline( sigl )
  
  drop _execio.
  exit 20
  
usageMsg :

  call lineout !, 'EXECIO:' arg(1)'.'
  call lineout !, ''  
  call lineout !, 'Usage:'  
  call lineout !, '  EXECIO {lines | *} DISKW ddname'  
  call lineout !, '    [( [STEM stem.] [OPEN] [FINIS] [)]]'  
  call lineout !, ''  
  call lineout !, 'Or:'  
  call lineout !, '  EXECIO {lines|*} DISKR|DISKRU ddname [firstLine] '  
  call lineout !, '    [( [FIFO|LIFO|STEM stem.] [OPEN] [FINIS] [SKIP] [)]]'  
  
  drop _execio.
  exit 20
