/* preprocess.rex

 tbd: include 'fil' => no path search
 tbd: include fil   => path search .. R4INCLUDE

 tbd: prepare exhaustive test file -- save results in comparison file !
  
  # define macro( a( b ), c( d( e, f ) ) ) ...

 test cases: 
  -- see testPreprocess.rex .. general tests
  -- see testPrepIf.rex .. '# if' tests
      also, see testPrepIf2.rex .. just one problem '# if' test

 usage:
  r4 symbol[(value)]* < inFile > outFile
  
 examples:
  r4 _debug < inFile.java > outFile.java

  r4 _prog(2000) < calc.cbl > CALC2000
  
 the PREPROCESS program is a s-i-m-p-l-e
 source file preprocessor.

 Notes are added as follows:
 
  # note text...
 
  # warning text...
 
  # error text...
 
 A series of symbols can be 'defined' on the
 command line.
 
 Other symbols can be defined in the source as follows:
  #define _other
  
 Then, a segment can be optionally emitted as follows:
  # ifdef _debug
  trace 'I'
  # endif
  
 More complex conditional processing is supported:

  # define this

  # define that

  # if defined( this ) && defined( that )
    'this' and 'that' are defined
  # elif ! defined( theother )
    'this' and 'that' are NOT defined
    'theother' is NOT defined
  # else
    'this' and 'that' are NOT defined
    'theother' IS defined
  # endif
 
  
 Substitutable symbols are supported:
 
    # define LOW_LIMIT 1
   
    # define HIGH_LIMIT  100

    if \ range( n, LOW_LIMIT, HIGH_LIMIT  ) then
      ...
      
 becomes:
  
    if \ range( n, 1, 100 ) then
      ...
  
 Macro definitions are supported:
 
    # define inc( V, I ) \
       V = V + I

    inc( index, increment )
      
 becomes:
  
    index = index + increment
    
    -- Note: the macro definition must be similar to
    the one above. The left parenthesis must be the
    end of the macro name. Spaces must separate the
    parentheses. Comma delimiters must be followed
    by a space.
    
    -- macro references must be within a single line
    
    -- C-like escape characters (\) are supported
    within macro references
  
 Line escapes in substitutable symbols are supported:
 
    # define WORD_LIST , \
       'abra' , \
       'ca' , \
       'dabra'   

    if wordpos( magic, WORD_LIST ) > 0 then
      ...
      
 becomes:

    if wordpos( magic, , 
       'abra' , 
       'ca' , 
       'dabra' ) > 0 then
      ...
  
 Other files can be added to the output stream as follows:
  # include "otherFile"
 Or, 
  # include 'otherFile'
 Or, 
  # include otherFile
  
 lines that start with '-- ' are comments, even if they do not start in column 1

 text following ' -- ' is commentary .. in preprocessor orders only
  
 ---
  
 CAVEATS:
 
  1. symbol names are processed in upper case
      _debug and _DEBUG are the same
  
  2. Substitutable symbols with empty values are not supported:
 
       # define EMPTY

       case 1 :
         EMPTY
        
     is unchanged and becomes:
    
       case 1 :
         EMPTY
         
     but, symbol EMPTY is still useable in:
     
       # ifdef EMPTY
*/                                           

metaCh = '#'

bDebugIfdef = 0

if lines() = 0 then do
  call lineout !, 'The input file is empty.'
  call lineout !, ''
  signal usagemsg
  end
  
symbols = arg( 1 )
  
fil = ''     /* initial input is from default input */

prep_symbols = ''

prep_macros = ''

symbol. = 0

define. = ''
define.0 = 0

macro. = ''
macro.0 = 0

priorEmpty. = 0

do while symbols <> ''

  parse var symbols symbol symbols

  parse UPPER var symbol symname '(' symval ')'
  
  if symval <> '' then do
    symbol = symname
    call _symbol2
    end
    
  else
    symbol.symbol = 1
  
  end
  
emit. = 1

anyemit. = 0

level = 0

lno = 0
  
do while lines( fil ) > 0

  depth = 1
  
  call processLine ''
  
  end
  
if queued() > 0 then do
  call lineout !, 'There are' queued() 'unclosed #if directives'  
  call lineout !, 'The first unclosed #if directive was on line' lastIf
  end
  
call lineout !, 'Done...' wave( 'tada' )

if bDebugIfdef then
  call lineout !, 'Level at end:' level


exit 0
  
include : /* procedure expose lin emit. symbol. depth */

  prev_file.depth = fil

  parse arg lno, fil
  
  fil = strip( fil )
  
  if pos( left( fil, 1 ), '"''' ) > 0 then do
  
    parse var fil  quotech +1 fil
  
    if right( fil, 1 ) <> quotech then do
      call lineout !, 'Mismatched quotes in file name to include on line #' lno
      call lineout !, '  'lin wave( 'ding' )
      exit 1
      end
  
    fil = left( fil, length( fil ) - 1 )
  
    end
  
  else if verify( fil, '"''', 'M' ) > 0 then do
    call lineout !, 'Unexpected quote in file name to include on line #' lno
    call lineout !, '  'lin wave( 'ding' )
    exit 1
    end
  
  if fil = '' then do
    call lineout !, 'Empty file name encountered on line #' lno
    call lineout !, '  'lin wave( 'ding' )
    exit 1
    end
  
  if \ stream( fil, 'C', 'Exists' ) then do
    call lineout !, 'Unknown file to include encountered on line #' lno
    call lineout !, '  'lin wave( 'ding' )
    exit 1
    end
    
  call lineout !, 'Including:' fil

  depth = depth + 1
  
  queuedBefore = queued()
  
  lno = 0
  
  do while lines( fil ) > 0
    call processLine fil
    end
  
  if queued() > queuedBefore then do
    call lineout !, ,
      'There are' queued() - queuedBefore 'unclosed #if directives' ,
      'in file:' fil
    call lineout !, 'The first unclosed #if directive was on line' lastIf
    end

  depth = depth - 1
    
  call lineout fil /* close the included file */

  fil = prev_file.depth
  
  return
  
getLine : /* procedure */

  lno = lno + 1

  lin = strip( linein( fil ), 'T' )
  
  if right( lin, 1 ) = '\' then do
  
    lin = left( lin, length( lin ) - 1 )
    
    lin = lin || '0a0d'x || getline() /* recurse */
    
    end
  
  return lin
  
subst : /* procedure */

  if ( pos( '__', lin ) + define.0 + macro.0 ) = 0 then
    return lin

  pre_subst_lin = lin

  if pos( '__', lin ) > 0 then do

    if pos( '__LINE__', lin ) > 0 then do
      parse var lin bef '__LINE__' aft
      lin = bef || lno || aft
      end

    if pos( '__FILE__', lin ) > 0 then do
      parse var lin bef '__FILE__' aft
      lin = bef || choice( fil <> '', fil, '>nofile<' ) || aft
      end
      
    if pos( '__DATE__', lin ) > 0 then do
      parse var lin bef '__DATE__' aft
      parse value date() with dd mmm yyyy
      lin = bef || mmm dd yyyy || aft
      end
      
    if pos( '__TIME__', lin ) > 0 then do
      parse var lin bef '__TIME__' aft
      lin = bef || time() || aft
      end
      
    if pos( '__YEAR__', lin ) > 0 then do
      parse var lin bef '__YEAR__' aft
      
      /* note: this is ONE YEAR AHEAD */
      
      if word( date(), 3 ) = 2006 then
        lin = bef || '2007' || aft
        
      else
        lin = bef || word( date(), 3 ) || aft
      
      end
    
    end

  do ss=1 for define.0
  
    parse var define.ss symbol symval

    lin = changeStr( symbol, lin, symval )
  
    end ss
    
  do mm=1 for macro.0
  
    do while wordpos( macro.mm, lin ) > 0
  
      macroName = macro.mm

      macroTerms = macro.macroName.terms 

      macroValue = macro.macroName.value

      parse var lin bef (macroName) macroArgs ')' aft
      
      nMacroArgs = getArgs( macroArgs )
      
      if nMacroArgs <> words( macroTerms ) then do
        call lineout !, "Incorrect argument count in: '"macroName"' reference."
        call lineout !, words( macroTerms ) 'arguments were expected,' nMacroArgs 'arguments were present.' 
        call lineout !, 'Error occurred in:' fil 'line #' lno
        call lineout !, '  'pre_subst_lin wave( 'ding' )
        exit 2
        end 
      
      do aa=1 for nMacroArgs
      
        parse var macroTerms term macroTerms
        
        macroValue = changeStr( term, macroValue, strip( MACARG.aa ) )
        end

      lin = bef || macroValue || aft
    
      end

    end mm

  return lin
  
processLine : /* procedure */

/* debug:

  do pl_ix = level to 0 by -1
    call lineout !, ,
      'level' pl_ix '-- emit.level' emit.pl_ix '-- anyemit.level' anyemit.pl_ix
    end pl_ix
    
*/     

  lno = lno + 1
  
  if 0 = ( lno // 1000 ) then
    call charout !, lno' '
  
  parse value strip( linein( fil ), 'T' ) with ,
      lin ,
    1 orderch +1 order symbol rest ,
    1 . +1 . inclfile ,
    1 orig_lin
    
  rest = strip( rest )
    
  inclfile = strip( inclfile )

/* debug:
  call lineout !, 'line' lin
*/     

/*
  symbol = translate( symbol ) /* changed: 20050204 */
*/     
    
  if word( lin, 1 ) = '--' then
    return /* skip comment lines -- changed: 20050202 */
  
  if orderch <> metaCh then do

    if emit.level then do
    
      if lin = '' then do
      
        /* when multiple empty lines are present
           only one empty line is emitted
         */
        
        if priorEmpty.depth then
          return
        
        priorEmpty.depth = 1
        
        end
        
      else
        priorEmpty.depth = 0
    
      say subst( lin )
      
      end
      
    return
    end
    
  /* text following ' -- ' is commentary in preprocessor orders */
    
  if pos( ' -- ', lin ) > 0 then do
  
    parse var lin lin ' -- ' .   /* changed: 20050222 */
    
    parse value strip( lin, 'T' ) with ,
      lin ,
      1 orderch +1 order symbol rest ,
      1 . +1 . inclfile
      
    end
    
  rest = strip( rest )
    
  inclfile = strip( inclfile )
    
  signal on syntax name _otherwise
  
/* ifdef/else/endif debugging note:

  say 'emit.'level emit.level lno lin
*/  
    
  signal value '_'strip( order )
  
_meta :

  newMetaCh = strip( symbol )

  if rest <> '' ,
   | length( newMetaCh ) <> 1 then do
    
    call lineout !, 'A single meta-character is expected in line:'
    
    call lineout !, '  'orig_lin
    
    if fil <> '' then
      call lineout !, 'Error in file' fil 'line#' lno
    else
      call lineout !, 'Error in line#' lno

    exit 99
    
    end /* words( lin ) <> 2 */
  
  metaCh = newMetaCh
  
  call lineout !, '!!! Using meta-character:' metaCh

  return  
  
_define :

  if emit.level then do

    if right( symbol, 1 ) = '(' then do
    
      /* macro definition */
    
      macroName = symbol /* includes trailing '(' */
            
      parse var rest _terms ')' rest
     
      if right( rest, 1 ) = '\' then
        rest = ,
          left( rest, length( rest ) - 1 ) ,
          || copies( '0a0d'x, rest <> '' ) || getLine()
        
      if pos( symbol, rest ) > 0 then do
      
        if fil <> '' then
          call lineout !, 'Error in file' fil 'line#' lno
        else
          call lineout !, 'Error in line#' lno
          
        call lineout !, ''
        call lineout !, 'Macro name can not appear in macro value...' 
        call lineout !, ''
        call lineout !, '  Macro name' macroName
        call lineout !, ''
        call lineout !, '  Macro value' rest wave( 'ding' )
        exit 99
        end

      macro.macroName.terms = ,
        space( translate( _terms, ' ', ',' ) )
        
      parse var rest rest_bef '0a0d'x rest_aft
      
      if rest_bef = '' then
        rest = rest_aft

      macro.macroName.value = rest
/*      
      macro.macroName.value = strip( translate( rest, '  ', '0a0d'x ) )
*/      
      
      if wordpos( macroName, prep_macros ) = 0 then do
        parse value ( macro.0 + 1 ) macroName with ,
          defIx . 1 macro.0 macro.defIx
        prep_macros = prep_macros macroName 
        end
      
      return
      
      end
      
    call lineout !, '0a0d'x lno '#define' symbol rest /* wave( 'ding' ) */

    symbol.symbol = rest || copies( '1', rest = '' )
    
    /* support symbol substitutions:
    
      # define LIMIT 100
      
      if n < LIMIT then
        ...
        
      becomes:

        if n < 100 then
          ...
      
     */
     
    if right( rest, 1 ) = '\' then
      symval = ,
        left( rest, length( rest ) - 1 ) ,
        || '0a0d'x || getLine()
    
    else
      symval = rest
      
    if left( symval, 2 ) = '0a0d'x then
      symval = substr( symval, 3 )

    /* this version does not do substitutions for empty symbols
       for example:
       
        # define _debug
        
        subsequent code references to '_debug' are not replaced
        
        but symbol.symbol is defined,
        thus a subsequent '# ifdef _debug' acts as expected
     */
    
    if symval = '' then
      return
      
    if pos( symbol, symval ) > 0 then do
    
      if fil <> '' then
        call lineout !, 'Error in file' fil 'line#' lno
      else
        call lineout !, 'Error in line#' lno
        
      call lineout !, ''
      call lineout !, 'Symbol name can not appear in symbol value...' 
      call lineout !, ''
      call lineout !, '  Symbol name' symbol
      call lineout !, ''
      call lineout !, '  Symbol value' symval wave( 'ding' )
      exit 99
      end
      
_symbol2 :      
      
    if wordpos( symbol, prep_symbols ) > 0 then do
      do def_ix=1 until word( define.def_ix, 1 ) = symbol
        end def_ix
      define.def_ix = symbol symval
      end /* wordpos( symbol, prep_symbols ) > 0 */
      
    else do
      parse value ( define.0 + 1 ) symbol symval with ,
        defIx . 1 define.0 define.defIx
        
      prep_symbols = prep_symbols symbol
      end
      
    end
    
  return
  
_if : /* added: 20050204 */

  if level = 0 then
    lastIf = lno
    
  /* this code processes 2 orders 'if' & 'elif'
     the nest level is only increased for 'if' orders.
   */

  level = level + ( order = 'if' )
  
  if \ value( 'EMIT.' || ( level - 1 ) ) then do
    emit.level = 0
    return
    end
  
  rest = symbol rest

  /* call lineout !, '# if' rest */
  
  if verify( rest, '!&|', 'M' ) > 0 then do
    rest = translate( rest, '\', '!' )
    rest = changestr( '&&', rest, '&' )
    rest = changestr( '||', rest, '|' )
      
    end

  do ss=1 for define.0
    parse var define.ss symbol symval
    rest = changeStr( symbol, rest, symval )
    end ss
  
  if pos( 'defined(', rest ) > 0 then do
  
    s = ''
    
    do while pos( 'defined(', rest ) > 0
      parse var rest before 'defined(' defsym ')' rest
      s = s || before'defined(' "'" || strip( defsym )"' )"
      end
      
    rest = s

    end
      
  /* call lineout !, '# if -->' rest */
    
  INTERPRET 'res =' rest

  emit.level = res

  anyemit.level = max( anyemit.level, emit.level )  

  return
  
_ifdef :

  if level = 0 then
    lastIf = lno

  level = level + 1

  emit.level = value( 'EMIT.' || ( level - 1 ) ) & ( symbol.symbol <> '0' )
  
  anyemit.level = emit.level

  if bDebugIfdef then
    call lineout !, '0a0d'x lno level '#ifdef' symbol /* wave( 'ding' ) */

  return
  
_ifndef :

  if level = 0 then
    lastIf = lno

  level = level + 1

  emit.level = value( 'EMIT.' || ( level - 1 ) ) & ( symbol.symbol = '0' )

  anyemit.level = emit.level

  if bDebugIfdef then
    call lineout !, '0a0d'x lno level '#ifndef' symbol /* wave( 'ding' ) */
  
  return
  
_else :

  if level < 1 then do
    call lineout !, 'Unexpected ELSE order in file:' fil 'line #' lno wave( 'ding' )
    exit 1
    end
    
/* debug:
trace i    
*/
    
  if ANYEMIT.level | \ value( 'EMIT.' || ( level - 1 ) ) then do
    emit.level = 0
    return
    end

  emit.level = \ ANYEMIT.level

  anyemit.level = emit.level

  return
  
_elif : /* added: 20050204 */

  if level < 1 then do
    call lineout !, 'Unexpected ELIF order in file:' fil 'line #' lno wave( 'ding' )
    exit 1
    end

/* debug:
trace i    
*/
    
  if ANYEMIT.level | \ value( 'EMIT.' || ( level - 1 ) ) then do
    emit.level = 0
    return
    end

/* oldver    
  if value( 'EMIT.' || ( level - 1 ) ) then
    emit.level = \ emit.level
*/    
    
  signal _if
  
_endif :

  if level < 1 then do
    call lineout !, 'Unexpected ENDIF order in file:' fil 'line #' lno wave( 'ding' )
    exit 1
    end

  emit.level = 0
  
  anyemit.level = 0
    
  level = level - 1

  if bDebugIfdef then
    call lineout !, '0a0d'x lno level '#endif' /* wave( 'ding' ) */
  
  return
  
_note :

  lin = subword( lin, 3 )

  if emit.level then
    call lineout !, copies( 'NOTE:' subst( lin ), lin <> '' )
    
  return  
  
_warning :

  lin = subword( lin, 3 )

  if emit.level then do

    call lineout !, copies( 'WARNING:' subst( lin ), lin <> '' )

    if lin <> 2 then
      call wave 'ding'
    end
    
  return  
  
_error :

  lin = subword( lin, 3 )

  if emit.level then do

    call lineout !, copies( 'ERROR:' subst( lin ), lin <> '' )

    if lin <> 2 then
      call wave 'ding'
    end
    
  return  

_undef :

  if emit.level then
    symbol.symbol = '0'
    
  return
  
_include :

  prev_metaCh = metaCh
  
  if emit.level then
    call include lno, inclfile

  metaCh = prev_metaCh
    
  return
  
_otherwise :

  if fil <> '' then
    call lineout !, 'Unrecognized preprocessor order in file:' fil 'line #' lno 

  else
    call lineout !, 'Unrecognized preprocessor order in line #' lno 
  
  call lineout !, '  'lin wave( 'ding' )
  
  exit 1

/*  
changeStr : procedure

  if pos( arg(2), arg(1) ) = 0 then
    return arg(1)  

  parse arg str, before, after

  res = ''

  do while str <> ''

    if pos( before, str ) = 0 then
      leave

    parse var str left (before) str

    res = res || left || after 

    end

  return res || str
*/  

choice : procedure
  return ,
       copies( arg( 2 ), arg( 1 ) <> 0 ) ,
    || copies( arg( 3 ), arg( 1 ) = 0 ) 
  
defined : /* procedure -- added: 20050204 */
  symname = arg(1)
  return SYMBOL.symname
/*
  return value( 'SYMBOL.'arg(1) ) = '1'
  return value( 'SYMBOL.' || translate( arg(1) ) ) = '1'
*/  

exists : /* procedure */
  return stream( arg(1), 'C', 'Exists' )

getArgs : procedure expose MACARG.

  argStr = strip( arg( 1 ) )

  nArguments = 0
  
  argument = ''

  do while argStr <> ''
  
    /* support C-like escape character */

    if left( argStr, 1 ) = '\' then do
    
      parse var argStr +1 whatever +1 argStr
      
      argument = argument || whatever
      
      iterate

      end
      
    /* an unescaped ',' ends an argument */
  
    if left( argStr, 1 ) = ',' then do

      nArguments = nArguments + 1

      MACARG.nArguments = strip( argument )
  
      argument = ''
      
      argStr = substr( argStr, 2 ) 
      
      /* special case: empty last argument */
      
      if argStr = '' then do

        nArguments = nArguments + 1

        MACARG.nArguments = ''
        
        leave
      
        end
      
      iterate

      end
      
    /* add a character to the argument */
      
    parse var argStr whatever +1 argStr
    
    argument = argument || whatever

    end /* while argStr <> '' */
    
  if argument <> '' then do

    nArguments = nArguments + 1

    MACARG.nArguments = strip( argument )

    end

  MACARG.0 = nArguments

  return nArguments
    
usagemsg :
  call lineout !, 'Usage:'
  call lineout !, ''
  call lineout !, '  r4 preprocess < inFile > outFile'
  
