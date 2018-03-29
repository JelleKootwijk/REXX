/* AnnVal.rex
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

request = value( "HKLM\Software\Kilowatt Software\R4\AnnVal[Request]", , "Registry" )

/* parse tab delimited request fields */

parse var request annuityAmount (tab) pctRate (tab) nyears

interest = ( pctRate / 100 ) / 12      /* convert annual interest rate to monthly rate */

compoundValue = 0

do i=1 to nyears
  compoundValue = trunc( compoundValue * ( ( 1 + interest ) ** 12 ), 2 )
  compoundValue = compoundValue + ( annuityAmount * ( 1 + interest ) )
  end

/* prepare tab delimited TopHat response -- only one value for this program */

response = compoundValue

'set R4REGISTRYWRITE=Y'   /* enable registry writing */

call value "HKLM\Software\Kilowatt Software\R4\AnnVal[Response]", response, "Registry"
