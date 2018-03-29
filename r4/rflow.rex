/* rflow.rex
 REXX program flow synopsis
 
 usage:
   r4 rflow < prog.rex > prog.flow
   
 description:
 
  this is a SIMPLE, yet helpful, program that
  extracts the control flow structure of a
  REXX program. it extracts source lines that
  begin with control instruction keywords and labels.
  lines that begin with '&' or '|' are also acquired,
  so compound IF and WHILE/UNTIL clauses that span source
  lines are extracted.
  
  the nesting depth associated with DO ... END
  groups is also maintained.  
   
 caveats:
 
  1) the program blithely ignores comments and
  quoted strings. consequently, lines
  within comments that begin with control
  instruction keywords will appear when they
  should be omitted. this simplicity can
  impair nesting depth analysis. for example,
  the nesting depth is incorrect if the word
  'do' appears in a comment or a quoted string
  on the same source line as an IF
  or other control instructions.
  
  2) the program obtains CALLs to subroutines
  but does not discover FUNCTION calls.
  
 example :
  r4 rflow < rflow.rex
  
 output : 
 
    4  +0  usage:
    7  +0  description:
   20  +0  caveats:
   36  +0  example :
   39  +0  output : 
   62  +1 do lno=1 for lines()
   66  +1   if lin = '' then iterate
   70  +1   if wordpos( word( up_lin, 1 ), ,
   72  +2    | wordpos( word( lin, 1 ), '& |' ) > 0 then do
   74  +2     if wordpos( 'DO', up_lin ) > 0 ,
   75  +2      & word( up_lin, 1 ) <> 'END' then
   80  +2     if word( up_lin, 1 ) = 'END' then
   83  +2     end
   85  +1   else if word( lin, 2 ) = ':' ,
   86  +1     | right( word( lin, 1 ), 1 ) = ':' then
   90  +1   end
   92  +0 exit 0
*/

nest = 0

do lno=1 for lines()

  lin = linein()
  
  if lin = '' then iterate
  
  up_lin = translate( lin )
  
  if wordpos( word( up_lin, 1 ), ,
      'IF DO END ELSE SELECT WHEN OTHERWISE ITERATE LEAVE CALL SIGNAL RETURN EXIT THEN' ) > 0 ,
   | wordpos( word( lin, 1 ), '& |' ) > 0 then do
   
    if wordpos( 'DO', up_lin ) > 0 ,
     & word( up_lin, 1 ) <> 'END' then
      nest = nest + 1
    
    say right( lno, 5 ) right( '+'nest, 3 ) lin

    if word( up_lin, 1 ) = 'END' then
      nest = nest - 1
    
    end

  else if word( lin, 2 ) = ':' ,
    | right( word( lin, 1 ), 1 ) = ':' then
    
    say right( lno, 5 ) right( '+'nest, 3 ) lin
    
  end
  
exit 0