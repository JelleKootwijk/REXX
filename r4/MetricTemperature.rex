/* MetricTemperature.rex
 this program converts metric temperatures -- CRC Handbook, p3

 this program communicates with TopHat.EXE via the registry

 the corresponding TopHat form definition is: Metric.TopHat

 a tab delimited request is received from registry value:
  HKLM\Software\Kilowatt Software\R4\MetricTemperature[Request]

 a tab delimited response is returned in registry value:
  HKLM\Software\Kilowatt Software\R4\MetricTemperature[Response]
*/

tab = d2c( 9 )

/* get TopHat request */

request = value( 'HKLM\Software\Kilowatt Software\R4\MetricTemperature[Request]', , 'Registry' )

/* parse tab delimited request fields */

parse var request ,
  fahrenheit        (tab) ,
/*  . (tab) , */ ,
  centigrade   (tab) ,

/* initialize all output values to empty strings */

parse value '' with ,
  o_centigrade     ,
  o_fahrenheit

/* compute values */

if fahrenheit <> '-' then
  o_centigrade = Trim( ( 5 / 9 ) * ( fahrenheit - 32 ) )

if centigrade <> '-' then
  o_fahrenheit = Trim( ( ( 9 / 5 ) * centigrade ) + 32 )

/* prepare tab delimited TopHat response */

response = ,
     o_centigrade     || tab ,
/*  || '' || tab , */ ,
  || o_fahrenheit     || tab

'set R4REGISTRYWRITE=Y'   /* enable registry writing */

call value 'HKLM\Software\Kilowatt Software\R4\MetricTemperature[Response]', response, 'Registry'

exit 0

Trim : procedure
  parse arg before '.' after
  if after = '' | after = '0' then
    return before
  return arg( 1 )
