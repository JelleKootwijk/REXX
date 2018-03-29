/* CompVal.rex
 this program computes the value of an investment,
 with interest compounded monthly

 this program communicates with TopHat.EXE via the registry

 a tab delimited request is received from registry value:
  HKLM\Software\Kilowatt Software\R4\LoanCalc[Request]

 a tab delimited response is returned in registry value:
  HKLM\Software\Kilowatt Software\R4\LoanCalc[Response]
*/

tab = d2c( 9 )

/* get TopHat request */

request = value( "HKLM\Software\Kilowatt Software\R4\CompVal[Request]", , "Registry" )

/* parse tab delimited request fields */

parse var request principal (tab) pctRate (tab) periodType (tab) nperiods

interest = ( pctRate / 100 ) / 12      /* convert annual interest rate to monthly rate */

if translate( left( periodType, 1 ) ) = 'Y' then
  nperiods = nperiods * 12                 /* #periods in a year */

compoundValue = trunc( principal * ( ( 1 + interest ) ** nperiods ), 2 )

/* prepare tab delimited TopHat response -- only one value for this program */

response = compoundValue

'set R4REGISTRYWRITE=Y'   /* enable registry writing */

call value "HKLM\Software\Kilowatt Software\R4\CompVal[Response]", response, "Registry"
