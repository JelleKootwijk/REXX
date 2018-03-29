/* KinematicEquations.rex
 this program computes a solution of a kinematic equation

  solves kinematic equations
  one of:

   x = vt

   v = v0 + a t

   x = v0 t + 1/2 a t^2

   v^2 = v0^2 + 2 a x

 this program communicates with TopHat.EXE via the registry

 a tab delimited request is received from registry value:
  HKLM\Software\Kilowatt Software\R4\KinematicEquations[Request]

 a tab delimited response is returned in registry value:
  HKLM\Software\Kilowatt Software\R4\KinematicEquations[Response]
*/

tab = d2c( 9 )

/* get TopHat request */

request = value( "HKLM\Software\Kilowatt Software\R4\KinematicEquations[Request]", , "Registry" )

response = '?' || tab || '?' || tab || '?' || tab || '?' || tab || '?'

'set R4REGISTRYWRITE=Y'   /* enable registry writing */

call value "HKLM\Software\Kilowatt Software\R4\KinematicEquations[Response]", response, "Registry"

/* parse tab delimited request fields */

/* trace ?r */

parse var request a (tab) t (tab) v0 (tab) v (tab) x (tab)

call validate 'acceleration', a

call validate 'time', t

call validate 'velocity', v

call validate 'initial velocity', v

call validate 'displacement', x

select

  /* x = vt */

  when x = '?' & Numeric( v ) & Numeric( t ) then do
    x = v * t
	parse value '' with v t a v0
    end

  when Numeric( x ) & v = '?' & Numeric( t ) then do
    v = x / t
	parse value '' with x t a v0
    end

  when Numeric( x ) & Numeric( v ) & t = '?' then do
    t = x / v
	parse value '' with x v a v0
    end

  /* v = v0 + a t */

  when v = '?' & Numeric( v0 ) & Numeric( a ) & Numeric( t ) then do
    v = v0  + ( a * t )
	parse value '' with v0 a t x
    end

  when Numeric( v ) & v0 = '?' & Numeric( a ) & Numeric( t ) then do
    v0 = v - ( a * t )
	parse value '' with v a t x
    end

  when Numeric( v ) & Numeric( v0 ) & a = '?' & Numeric( t ) then do
    a = ( v - v0 ) / t
	parse value '' with v v0 t x
    end

  when Numeric( v ) & Numeric( v0 ) & Numeric( a ) & t = '?' then do
    t = ( v - v0 ) / a
	parse value '' with v v0 a x
    end

  /*  x = v0 t + 1/2 a t^2 */

  when x = '?' & Numeric( v0 ) & Numeric( a ) & Numeric( t ) then do
    x = ( v0 * t )  + ( .5 * a * ( t * t ) )
	parse value '' with v0 a t v
    end

  when Numeric( x ) & v0 = '?' & Numeric( a ) & Numeric( t ) then do
    v0 = ( x - ( .5 * a * ( t * t ) ) ) / t
	parse value '' with x a t v
    end

  when Numeric( x ) & Numeric( v0 ) & a = '?' & Numeric( t ) then do
    a = ( 2 * ( x - ( v0 * t ) ) ) / ( t * t )
	parse value '' with x v0 t v
    end

  when Numeric( x ) & Numeric( v0 ) & Numeric( a ) & t = '?' then do
    t = quadraticRoots( .5 * a, v0, 0 - x )
	parse value '' with x v0 a v
    end

  /* v^2 = v0^2 + 2 a x */

  when v = '?' & Numeric( v0 ) & Numeric( a ) & Numeric( x ) then do
    v = squareroot( ( v0 * v0 )  + ( 2 * a * x ) )
	parse value '' with v0 a x t
    end

  when Numeric( v ) & v0 = '?' & Numeric( a ) & Numeric( x ) then do
    v0 = squareroot( ( v * v )  - ( 2 * a * x ) )
	parse value '' with v a x t
    end

  when Numeric( v ) & Numeric( v0 ) & a = '?' & Numeric( x ) then do
    a = ( ( v * v ) - ( v0 * v0 ) ) / ( 2 * x )
	parse value '' with v0 v x t
    end

  when Numeric( v ) & Numeric( v0 ) & Numeric( a ) & x = '?' then do
    x = ( ( v * v ) - ( v0 * v0 ) ) / ( 2 * a )
	parse value '' with v v0 a t
    end

  otherwise
    msgbox 'Unknown combination, please try again...'
	return 99

  end

/* prepare tab delimited TopHat response  */

response = a || tab || t || tab || v0 || tab || v || tab || x

call value "HKLM\Software\Kilowatt Software\R4\KinematicEquations[Response]", response, "Registry"

return 0

/* 'quadraticRoots' procedure

   find the roots of a kinematic equations
*/

quadraticRoots : procedure expose root1 root2
  parse arg a, b, c

  if a = 0 then
    call usage2 'The first coefficient of a kinematic equations is 0 (invalid).'

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
  
  return root1 ';' root2

validate : procedure
  parse arg which, v

  if v <> '?' & v <> '-' & \ Numeric( v ) then
    call usage1 which, v

  return

Numeric : procedure
  return datatype( arg(1), 'Number' ) 

usage1 : procedure
  parse arg which, v
  'msgbox' 'Value' which 'is non-numeric. It''s' v
  exit 99

usage2 : procedure
  'msgbox' arg(1)
  exit 99
