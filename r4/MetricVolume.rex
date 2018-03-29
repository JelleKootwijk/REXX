/* MetricVolume.rex
 this program converts metric volumes -- CRC Handbook, p3

 this program communicates with TopHat.EXE via the registry

 the corresponding TopHat form definition is: Metric.TopHat

 a tab delimited request is received from registry value:
  HKLM\Software\Kilowatt Software\R4\MetricVolume[Request]

 a tab delimited response is returned in registry value:
  HKLM\Software\Kilowatt Software\R4\MetricVolume[Response]
*/

tab = d2c( 9 )

/* get TopHat request */

request = value( 'HKLM\Software\Kilowatt Software\R4\MetricVolume[Request]', , 'Registry' )

/* parse tab delimited request fields */

parse var request ,
  cubicInches        (tab) ,
  cubicFeet          (tab) ,
  cubicYards         (tab) ,
/*  . (tab) , */ ,
  fluidOunces        (tab) ,
  quarts             (tab) ,
  gallons            (tab) , 
/*  . (tab) , */ ,
  cubicCentimeters   (tab) ,
  cubicMetersToFeet  (tab) ,
  cubicMetersToYards (tab) , 
/*  . (tab) , */ ,
  milliliters        (tab) ,
  litersToQuarts     (tab) ,
  litersToGallons    (tab)

/* initialize all output values to empty strings */

parse value '' with ,
  o_cubicCentimeters     ,
  o_cubicMetersFromFeet  ,
  o_cubicMetersFromYards ,
  o_milliliters          ,
  o_litersFromQuarts     ,
  o_litersFromGallons	 ,
  o_cubicInches          ,
  o_cubicFeet            ,
  o_cubicYards           ,
  o_fluidOunces          ,
  o_quarts               ,
  o_gallons

/* compute values */

if cubicInches <> '-' then
  o_cubicCentimeters = Trim( cubicInches * 16.387064 )

if cubicFeet <> '-' then
  o_cubicMetersFromFeet = Trim( cubicFeet * .02831684659 )

if cubicYards <> '-' then
  o_cubicMetersFromYards = Trim( cubicYards * .764554858 )

if fluidOunces <> '-' then
  o_milliliters = Trim( fluidOunces * 29.57352956 )

if quarts <> '-' then
  o_litersFromQuarts = Trim( quarts * ( 3.785411784 / 4 ) )

if gallons <> '-' then
  o_litersFromGallons = Trim( gallons *  3.785411784 )

if cubicCentimeters <> '-' then
  o_cubicInches = Trim( cubicCentimeters * .06102374409 )

if cubicMetersToFeet <> '-' then
  o_cubicFeet = Trim( cubicMetersToFeet * 35.31466672 )

if cubicMetersToYards <> '-' then
  o_cubicYards = Trim( cubicMetersToYards * 1.307950619 )

if milliliters <> '-' then
  o_fluidOunces = Trim( milliliters * .0338140227 )

if litersToQuarts <> '-' then
  o_quarts = Trim( litersToQuarts * ( .2641720524 / 4 ) )

if litersToGallons <> '-' then
  o_gallons = Trim( litersToGallons * .2641720524 )

/* prepare tab delimited TopHat response */

response = ,
     o_cubicCentimeters     || tab ,
  || o_cubicMetersFromFeet  || tab ,
  || o_cubicMetersFromYards || tab ,
/*  || '' || tab , */ ,
  || o_milliliters          || tab ,
  || o_litersFromQuarts     || tab ,
  || o_litersFromGallons    || tab ,
/*  || '' || tab , */ ,
  || o_cubicInches          || tab ,
  || o_cubicFeet            || tab ,
  || o_cubicYards           || tab ,
/*  || '' || tab , */ ,
  || o_fluidOunces          || tab  ,
  || o_quarts               || tab  ,
  || o_gallons              || tab              

'set R4REGISTRYWRITE=Y'   /* enable registry writing */

call value 'HKLM\Software\Kilowatt Software\R4\MetricVolume[Response]', response, 'Registry'

exit 0

Trim : procedure
  parse arg before '.' after
  if after = '' | after = '0' then
    return before
  return arg( 1 )
