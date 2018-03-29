/* primeFactors.rex
 this program identifies all of the unique prime factors that can divide a number.

 1 and the number itself are not added to the list of prime factors.
*/

arg n

if n = '' then
  signal usagemsg

if \ datatype( n,  'WholeNumber' ) then
  signal usagemsg

if n < 4 then
  signal usagemsg

numeric digits 20

n = arg( 1 )

factors = ''

factor. = 0

do i=2

  factor = i

  do while 0 = ( n // i )
    if \ factor.i then do
      factors = factors factor
	  factor.i = 1
	  end
	factor = factor * i
	n = n / i
	end

  if i > ( n / 2 ) then do 
    if factors <> '' & n <> 1 then
	  factors = factors n
    leave
    end

  end

if factors <> '' then
  say 'prime factors(' arg( 1 ) ') =>'factors

else
  say arg( 1 ) 'is a PRIME number.'

exit 0

usagemsg :
  call lineout !, 'Please enter a whole number above 3 to factor...'
  call lineout !, ''
  call lineout !, 'Usage:'
  call lineout !, '  r4 primeFactors N'
  exit 99