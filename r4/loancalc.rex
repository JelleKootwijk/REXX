/* LoanCalc.rex
 this program computes loan payment values

 this program communicates with TopHat.EXE via the registry

 a tab delimited request is received from registry value:
  HKLM\Software\Kilowatt Software\R4\LoanCalc[Request]

 a tab delimited response is returned in registry value:
  HKLM\Software\Kilowatt Software\R4\LoanCalc[Response]
*/

tab = d2c( 9 )

/* get TopHat request */

request = value( 'HKLM\Software\Kilowatt Software\R4\LoanCalc[Request]', , 'Registry' )

/* parse tab delimited request fields */

parse var request downPayment (tab) principal (tab) pctRate (tab) periodType (tab) nperiods

/* compute loan payment values */

workingPrincipal = principal - downPayment

interest = ( pctRate / 100 ) / 12      /* convert annual interest rate to monthly rate */

if translate( left( periodType, 1 ) ) = 'Y' then
  nperiods = nperiods * 12                 /* #payments in a year */

x = ( 1 + interest ) ** nperiods

monthly = ( workingPrincipal * x * interest ) / ( x - 1 )

monthlyPayment = trunc( monthly, 2 )

total = monthly * nperiods

totalPayment = trunc( total, 2 )

totalInterest = trunc( total - principal, 2 )

totalExpense = trunc( total + downPayment, 2 )

/* prepare tab delimited TopHat response */

response = monthlyPayment || tab || totalPayment || tab || totalInterest || tab || totalExpense

'set R4REGISTRYWRITE=Y'   /* enable registry writing */

call value 'HKLM\Software\Kilowatt Software\R4\LoanCalc[Response]', response, 'Registry'
