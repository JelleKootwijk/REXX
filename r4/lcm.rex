/* lcm.rex
 least common multiple

 usage
  r4 LCM n1 n2

  where
   n1 is a positive whole number
   n2 is a positive whole number
*/

parse arg a b .

if b = '' then call usagemsg

if \ datatype( a, 'Whole' ) then
  call usagemsg 'The 1st argument ('a') must be a positive whole number'

if a < 1 then
  call usagemsg 'The 1st argument ('a') must be a positive whole number'

if \ datatype( b, 'Whole' ) then
  call usagemsg 'The 1st argument ('||b||') must be a positive whole number'

if b < 1 then
  call usagemsg 'The 1st argument ('||b||') must be a positive whole number'

say ( a * b ) / gcd( a, b )

exit 0

gcd : procedure
  parse arg a, b
  if b = 0 then return a
  return gcd( b, a // b )

usagemsg : procedure
  if arg(1) <> '' then do
    call lineout !, 'Note:' arg(1)
    call lineout !, ''
	end
  call lineout !, 'Usage:'
  call lineout !, ' r4 LCM n1 n2'
  exit 1
