/* sayit.rex
 believe it or not this is a full function calculator
 and it can perform string computations as well

 normally, the program interprets its arguments as
 a REXX expression, and says the result.

 the number of numeric digits can optionally be specified.
 when the 2nd argument word is a '!', the first argument word
 is the number of numeric digits to use, and the remaining
 argument words are processed as a numeric expression.

 usage:
  r4 sayit rexxExpression

 optional usage:
  r4 sayit ndigits ! numericExpression

 examples:

  r4 sayit max( 123456789.3, 123456789.7 ) -- yields: 123456790

  r4 sayit 10 ! max( 123456789.3, 123456789.7 ) -- yields: 123456789.7

  r4 sayit 1 / 243

  r4 sayit 100 ! 1 / 243

  r4 sayit length( 'abra ca dabra' )

  r4 sayit word( 'abra ca dabra', 3 )
*/

if word( arg(1), 2 ) = '!' then do

  parse arg n '!' rest

  numeric digits n

  interpret say rest

  end

else

  interpret say arg( 1 )
