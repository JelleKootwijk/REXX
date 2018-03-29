/* QuadraticFormula.rex
 this program computes roots of a quadratic equation

 this program communicates with TopHat.EXE via the registry

 a tab delimited request is received from registry value:
  HKLM\Software\Kilowatt Software\R4\QuadraticFormula[Request]

 a tab delimited response is returned in registry value:
  HKLM\Software\Kilowatt Software\R4\QuadraticFormula[Response]
*/

tab = d2c( 9 )

/* get TopHat request */

request = value( "HKLM\Software\Kilowatt Software\R4\QuadraticFormula[Request]", , "Registry" )

response = '?' || tab || '?'

'set R4REGISTRYWRITE=Y'   /* enable registry writing */

call value "HKLM\Software\Kilowatt Software\R4\QuadraticFormula[Response]", response, "Registry"

/* parse tab delimited request fields */

parse var request a (tab) b (tab) c

if \ datatype( a, 'Number' ) then
  call usage1 'a' a

if \ datatype( a, 'Number' ) then
  call usage2 'b' b

if \ datatype( a, 'Number' ) then
  call usage3 'c' c

call quadraticRoots a b c

/* prepare tab delimited TopHat response  */

response = root1 || tab || root2

call value "HKLM\Software\Kilowatt Software\R4\QuadraticFormula[Response]", response, "Registry"

return 0

/* 'quadraticRoots' procedure

   find the roots of a quadratic equation
*/

quadraticRoots : procedure expose root1 root2
  parse arg a b c

  if a = 0 then
    call usage2 'The first coefficient of a quadratic equation is 0 (invalid).'

  twoA = a * 2

  subterm = ( b * b ) - ( 4 * a * c )

  subtermSign = sign( subterm )

  subterm = abs( subterm )

  subroot = squareroot( subterm )

  if subtermSign <> -1 then
    root1 = ( subroot - b ) / twoA
  else
    root1 = ( 0 - b ) / twoA '+' ( subroot / twoA ) 'i'

  if subtermSign <> -1 then
    root2 = ( 0 - ( subroot + b ) ) / twoA
  else
    root2 = ( 0 - b ) / twoA '-' ( subroot / twoA ) 'i'
  
  return

usage1 : procedure
  parse arg which v
  'msgbox' 'Value' which 'is non-numeric. It''s' v
  exit 99

usage2 : procedure
  'msgbox' arg(1)
  exit 99
