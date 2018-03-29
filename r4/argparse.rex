/* argparse.rex -- EXTERNAL PROCEDURE
 parse TSO-style command line arguments
 
 the command line is received as arg(1)
 
 one line is queued per argument
 
 each queued line either contains:
  1. a keyword followed by a value
  2. or a single value which might be quoted
  
 RESULT:
  '' -- successful completion
  'ARGPARSE: ...error text...'
  
 consider the TSO command:
  alloc fi(filename) da('xxx.yyy(mem)') shr
  
 the arguments that would be passed to ARGPARSE are:
  fi(filename) da('xxx.yyy(mem)') shr
  
 the lines that would be returned are:
  fi filename
  da 'xxx.yyy(mem)'
  shr
  
 the calling program must decipher keyword abbreviations:
  fi => file
  da => dataset
  
 CAVEATs:
  
  1. this implementation does not handle interior quotes within arguments
  
  2. only one level of nested parentheses is supported in keyword values,
     for example:
       da(xxx.yyy(mem))
  
 example usage:
 
  cmdLine = "alloc fi(filename) da('xxx.yyy(mem)') shr"
 
  parse var cmdLine cmd cmdArgs
 
  'newstack'
  
  errorText = argparse( cmdArgs )
  
  if errorText <> '' then do
    say 'ARGPARSE error:' errorText
    exit 12
    end
    
  else
  do argNo=1 for queued()
  
    PULL qline /* uppercase text */
    
    if pos( left( qline, 1 ), "'""" ) > 0 , /* quoted value */
     | words( qline ) = 1 then /* unquoted value */
      say argNo'.' qline
      
    else do
      parse var qline keyword value
      say argNo'. Keyword('keyword') Value('value')'
      end
  
    end argNo
  
  'delstack'
  
   .
   . (proceed with command processing)
   .
   
  exit 0
*/

cmdArgs = strip( arg(1) )

if cmdArgs = '' then
  return 'ARGPARSE: No arguments'

do argNo=1 while cmdArgs <> ''

  /* process "quoted" value */
  
  if pos( left( cmdArgs, 1 ), "'""" ) > 0 then do /* quoted value */
  
    quotedValue = getQuotedValue()
    
    queue quoteCh || quotedValue || quoteCh
    
    end /* quoted value */

  /* process keyword(value) argument */
    
  else if pos( '(', word( cmdArgs, 1 ) ) > 0 then do
  
    origArgs = cmdArgs
  
    parse var cmdArgs keyword '(' cmdArgs
    
    if pos( ')', cmdArgs ) = 0 then
      return 'ARGPARSE. Argument('argNo') missing right parenthesis:' origArgs 

    cmdArgs = strip( cmdArgs, 'L' )
      
    if pos( left( cmdArgs, 1 ), "'""" ) > 0 then do /* quoted keyword value */
    
      quotedKeywordValue = getQuotedValue( 'OPTSPACE' )
    
      if left( cmdArgs, 1 ) <> ')' then
        return 'ARGPARSE. Argument('argNo') missing right parenthesis:' origArgs 
        
      cmdArgs = substr( cmdArgs, 2 )
        
      queue keyword quoteCh || quotedKeywordValue || quoteCh

      end  /* quoted keyword value */
    
    else if pos( '(', word( cmdArgs, 1 ) ) > 0 then do  /* unquoted keyword value with '(' */
    
      parse var cmdArgs unquotedKeywordValue '(' unquotedKeywordValueRest ')' cmdArgs

      cmdArgs = strip( cmdArgs, 'L' )
    
      if left( cmdArgs, 1 ) <> ')' then
        return 'ARGPARSE. Argument('argNo') missing right parenthesis:' origArgs 

      cmdArgs = strip( substr( cmdArgs, 2 ), 'L' )

      queue keyword unquotedKeywordValue'('unquotedKeywordValueRest')'
    
      end /* unquoted keyword value with '(' */
    
    else do /* unquoted keyword value without '(' */
    
      parse var cmdArgs unquotedKeywordValue ')' cmdArgs
      
      if cmdArgs <> '' & left( cmdArgs, 1 ) <> ' ' then
        return 'ARGPARSE. Argument('argNo') space expected at:' cmdArgs 
    
      queue keyword unquotedKeywordValue    
    
      cmdArgs = strip( substr( cmdArgs, 2 ), 'L' )
    
      end /* unquoted keyword value without '(' */
  
    end /* keyword(value) argument */

  /* process "unquoted" value */
    
  else do
    parse var cmdArgs unquotedValue cmdArgs
    queue unquotedValue    
    end /* unquoted value */

  end argNo
  
return '' /* successful completion */

getQuotedValue : /* procedure */
  
  quoteCh = left( cmdArgs, 1 )
  
  if pos( quoteCh, substr( cmdArgs, 2 ) ) = 0 then
    exit 'ARGPARSE. Argument('argNo') is improperly quoted:' cmdArgs 
  
  parse var cmdArgs +1 quotedValue (quoteCh) cmdArgs
      
  if cmdArgs <> '' ,
   & left( cmdArgs, 1 ) <> ' ' ,
   & arg(1) <> 'OPTSPACE' then
    return 'ARGPARSE. Argument('argNo') space expected at:' cmdArgs 
  
  cmdArgs = strip( cmdArgs, 'L' )
  
  return quotedValue
