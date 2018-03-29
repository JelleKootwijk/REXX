/* MetricWeight.rex
 this program converts metric weights -- CRC Handbook, p3

 this program communicates with TopHat.EXE via the registry

 the corresponding TopHat form definition is: Metric.TopHat

 a tab delimited request is received from registry value:
  HKLM\Software\Kilowatt Software\R4\MetricWeight[Request]

 a tab delimited response is returned in registry value:
  HKLM\Software\Kilowatt Software\R4\MetricWeight[Response]
*/

tab = d2c( 9 )

/* get TopHat request */

request = value( 'HKLM\Software\Kilowatt Software\R4\MetricWeight[Request]', , 'Registry' )

/* parse tab delimited request fields */

parse var request ,
  ounces        (tab) ,
  pounds        (tab) ,
/*  . (tab) , */ ,
  grams   (tab) ,
  kilograms   (tab) ,

/* initialize all output values to empty strings */

parse value '' with ,
  o_grams     ,
  o_kilograms ,
  o_ounces    ,
  o_pounds

/* compute values */

if ounces <> '-' then
  o_grams = Trim( ounces * 28.34952313 )

if pounds <> '-' then
  o_kilograms = Trim( pounds * .45359237 )

if grams <> '-' then
  o_ounces = Trim( grams * .03527396195 )

if kilograms <> '-' then
  o_pounds = Trim( kilograms * 2.204622622 )

/* prepare tab delimited TopHat response */

response = ,
     o_grams     || tab ,
  || o_kilograms || tab ,
/*  || '' || tab , */ ,
  || o_ounces    || tab ,
  || o_pounds    || tab

'set R4REGISTRYWRITE=Y'   /* enable registry writing */

call value 'HKLM\Software\Kilowatt Software\R4\MetricWeight[Response]', response, 'Registry'

exit 0

Trim : procedure
  parse arg before '.' after
  if after = '' | after = '0' then
    return before
  return arg( 1 )
