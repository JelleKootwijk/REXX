/* gcd.rex
 greatest common divisor

 usage
  r4 GCD n1 n2 [UseAlternateAlgorithm]

  where
   n1 is a positive whole number
   n2 is a positive whole number
   UseAlternateAlgorithm indicates that an alternative algorithm is used (optional)
*/

parse arg a b algorithm .

if b = '' then call usagemsg

if \ datatype( a, 'Whole' ) then
  call usagemsg 'The 1st argument ('a') must be a positive whole number'

if a < 1 then
  call usagemsg 'The 1st argument ('a') must be a positive whole number'

if \ datatype( b, 'Whole' ) then
  call usagemsg 'The 1st argument ('||b||') must be a positive whole number'

if b < 1 then
  call usagemsg 'The 1st argument ('||b||') must be a positive whole number'

if algorithm = '' then
  say gcd( a, b )
else
  say gcd2( a, b )

exit 0

gcd : procedure
  parse arg a, b
  if b = 0 then return a
  if a < b then return gcd( b, a )
  return gcd( a-b, b )

gcd2 : procedure
  parse arg a, b
  if b = 0 then return a
  return gcd2( b, a // b )

usagemsg : procedure
  if arg(1) <> '' then do
    call lineout !, 'Note:' arg(1)
    call lineout !, ''
	end
  call lineout !, 'Usage:'
  call lineout !, ' r4 GCD n1 n2 [UseAlternateAlgorithm]'
  exit 1
