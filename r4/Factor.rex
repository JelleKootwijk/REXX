/* factor.rex
 this program identifies all of the factors that can divide a number.

 1 and the number itself are not added to the list of factors.
*/

numeric digits 20

arg n

if n = '' then
  signal usagemsg

if \ datatype( n,  'WholeNumber' ) then
  signal usagemsg

if n < 4 then
  signal usagemsg

factors = ''

do i=2 to n / 2

  if 0 = ( n // i ) then
    factors = factors i

  end

if factors <> '' then
  say 'factors(' arg( 1 ) ') =>'factors

else
  say arg( 1 ) 'is a PRIME number.'

exit 0

usagemsg :
  call lineout !, 'Please enter a whole number above 3 to factor...'
  call lineout !, ''
  call lineout !, 'Usage:'
  call lineout !, '  r4 factor N'
  exit 99