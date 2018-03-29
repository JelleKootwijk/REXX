/* MetricArea.rex
 this program converts metric areas -- CRC Handbook, p3

 this program communicates with TopHat.EXE via the registry

 the corresponding TopHat form definition is: Metric.TopHat

 a tab delimited request is received from registry value:
  HKLM\Software\Kilowatt Software\R4\MetricArea[Request]

 a tab delimited response is returned in registry value:
  HKLM\Software\Kilowatt Software\R4\MetricArea[Response]
*/

tab = d2c( 9 )

/* get TopHat request */

request = value( 'HKLM\Software\Kilowatt Software\R4\MetricArea[Request]', , 'Registry' )

/* parse tab delimited request fields */

parse var request ,
  squareInches        (tab) ,
  squareFeet          (tab) ,
  squareYards         (tab) ,
/*  . (tab) , */ ,
  squareCentimeters   (tab) ,
  squareMetersToFeet  (tab) ,
  squareMetersToYards (tab)  

/* initialize all output values to empty strings */

parse value '' with ,
  o_squareCentimeters     ,
  o_squareMetersFromFeet  ,
  o_squareMetersFromYards ,
  o_squareInches      ,
  o_squareFeet          ,
  o_squareYards

/* compute values */

if squareInches <> '-' then
  o_squareCentimeters = Trim( squareInches * 6.4516 )

if squareFeet <> '-' then
  o_squareMetersFromFeet = Trim( squareFeet * .09290304 )

if squareYards <> '-' then
  o_squareMetersFromYards = Trim( squareYards * .83612736 )

if squareCentimeters <> '-' then
  o_squareInches = Trim( squareCentimeters * .15500031 )

if squareMetersToFeet <> '-' then
  o_squareFeet = Trim( squareMetersToFeet * 10.76391042 )

if squareMetersToYards <> '-' then
  o_squareYards = Trim( squareMetersToYards * 1.195990046 )

/* prepare tab delimited TopHat response */

response = ,
     o_squareCentimeters     || tab ,
  || o_squareMetersFromFeet  || tab ,
  || o_squareMetersFromYards || tab ,
/*  || '' || tab , */ ,
  || o_squareInches          || tab ,
  || o_squareFeet            || tab ,
  || o_squareYards           || tab

'set R4REGISTRYWRITE=Y'   /* enable registry writing */

call value 'HKLM\Software\Kilowatt Software\R4\MetricArea[Response]', response, 'Registry'

exit 0

Trim : procedure
  parse arg before '.' after
  if after = '' | after = '0' then
    return before
  return arg( 1 )
