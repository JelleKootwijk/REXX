/* sieve.rex
 Eratosthenes prime number sieve algorithm
*/

arg limit                                             /* processing limit */

if datatype( limit, 'W' ) <> 1 then signal usagemsg

isPrime. = 1                           /* presume all numbers are prime ! */

do n=2 to limit

  if isPrime.n then
    call anotherPrime n

  end

exit 0

anotherPrime : procedure expose limit isPrime.
  arg prime
  
  say right( prime, length( limit ) )               /* emit current prime */

  do multiple=prime by prime to limit     /* mark multiples as non-primes */

    isPrime.multiple = 0             /* multiples of primes are not prime */

    end

  return

usagemsg :
  call lineout !, 'Usage'
  call lineout !, '  r4 sieve limit'
  exit 1