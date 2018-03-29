/* MetricDistance.rex
 this program converts metric distances -- CRC Handbook, p3

 this program communicates with TopHat.EXE via the registry

 the corresponding TopHat form definition is: Metric.TopHat

 a tab delimited request is received from registry value:
  HKLM\Software\Kilowatt Software\R4\MetricDistance[Request]

 a tab delimited response is returned in registry value:
  HKLM\Software\Kilowatt Software\R4\MetricDistance[Response]
*/

tab = d2c( 9 )

/* get TopHat request */

request = value( 'HKLM\Software\Kilowatt Software\R4\MetricDistance[Request]', , 'Registry' )

/* parse tab delimited request fields */

parse var request ,
  inches        (tab) ,
  feet          (tab) ,
  yards         (tab) ,
  miles         (tab) ,
/*  . (tab) , */ ,
  centimeters   (tab) ,
  metersToFeet  (tab) ,
  metersToYards (tab) ,
  kilometers    (tab)

/* initialize all output values to empty strings */

parse value '' with ,
  o_centimeters     ,
  o_metersFromFeet  ,
  o_metersFromYards ,
  o_kilometers      ,
  o_inches          ,
  o_feet            ,
  o_yards           ,
  o_miles

/* compute values */

if inches <> '-' then
  o_centimeters = Trim( inches * 2.54 )

if feet <> '-' then
  o_metersFromFeet = Trim( feet * .3048 )

if yards <> '-' then
  o_metersFromYards = Trim( yards * .9144 )

if miles <> '-' then
  o_kilometers = Trim( miles * 1.609344 )

if centimeters <> '-' then
  o_inches = Trim( centimeters * .3937007874 )

if metersToFeet <> '-' then
  o_feet = Trim( metersToFeet * 3.280839895 )

if metersToYards <> '-' then
  o_yards = Trim( metersToYards * 1.093613298 )

if kilometers <> '-' then
  o_miles = Trim( kilometers * .6213711922 )

/* prepare tab delimited TopHat response */

response = ,
     o_centimeters     || tab ,
  || o_metersFromFeet  || tab ,
  || o_metersFromYards || tab ,
  || o_kilometers      || tab ,
/*  || '' || tab , */ ,
  || o_inches          || tab ,
  || o_feet            || tab ,
  || o_yards           || tab ,
  || o_miles           || tab

'set R4REGISTRYWRITE=Y'   /* enable registry writing */

call value 'HKLM\Software\Kilowatt Software\R4\MetricDistance[Response]', response, 'Registry'

exit 0

Trim : procedure
  parse arg before '.' after
  if after = '' | after = '0' then
    return before
  return arg( 1 )
