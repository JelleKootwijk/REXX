/* factorial.rex

 usage:
  r4 factorial nnn
*/

numeric digits 20

	/* acquire and validate numeric argument */

arg n .

if datatype( n, 'W' ) = 0 then
  signal usagemsg

if n < 1 then
  signal usagemsg

say f( n )	/* recursively compute factorial */

exit

	/* procedure F
	 * returns factorial of argument N
	 */

f : procedure

  n = arg( 1 )

  if n = 1 then
	return 1
 
  return n * f( n - 1 )

	/* show usage information */

usagemsg :

 call lineout !, "Usage:"

 call lineout !, " r4  factorial nnn"

 call lineout !, " Where: nnn must be a positive whole number"
