/* sqrt.rex
 EXTERNAL PROCEDURE, computes square root of numeric argument
*/

arg n , nDigits .                       /* get number
                                         * and optional #digits of result
                                         */

if datatype( n ) <> 'NUM' then signal usagemsg

if n < 0 then signal usagemsg

if n = 0 then
  return 0 /* sqrt(0) is 0 ! */

if nDigits <> '' then do
  if datatype( nDigits, 'Whole' ) <> 1 then signal usagemsg
  numeric digits nDigits
  end


cycle = 0                                            /* initialize cycle count */

return sqrt( n, n / 3 )                              /* compute square root, recursively
                                                      * the initial stab is:
													  *  n divided by 3
                                                      */

 /* SQRT
  * Newton's algorithm
  * Practical Algorithms, p456
  */

sqrt : procedure expose cycle

  arg n, stab

  cycle = cycle + 1                                  /* increment cycle count */

  if cycle > 50 then return stab                        /* avoid loop ! */
  
  nextStab = ( n + ( stab * stab ) ) / ( 2 * stab )  /* compute next stab */

  if nextStab = stab then return stab                /* same => final value */

  return sqrt( n, nextStab )                         /* recurse */
  
usagemsg :
  call lineout !, 'Usage'
  call lineout !, ' r4 sayit SQRT( N [, #digits ] )'
  call lineout !, ''
  call lineout !, ' N must be greater than 0'
  call lineout !, ''
  call lineout !, ' #digits must be a whole number'
  exit 1