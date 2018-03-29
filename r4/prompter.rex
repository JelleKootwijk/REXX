/* prompter.rex
 demonstration program that uses PROMPT.EXE

 usage:
  r4 prompter [color]

 examples:

  1. r4 prompter		[ input field is initially empty ]

  2. r4 prompter Blue	[ shows color in input field ]

 refer to PROMPT.HTM for a description of the usage of PROMPT.EXE
*/
  
'set R4REGISTRYWRITE=Y'   /* enable registry writing */

if arg(1) <> '' then
  call value 'HKLM\Software\Kilowatt Software\Prompt[Response]', arg(1), 'Registry'

registryValue = 'Response'

noteText = 'What is your favorite color ?'

caption = 'Prompt -- enter your favorite color'

tab = d2c( 9 )

trace off /* ignore Cancel button error */

'set R4COMMANDWAIT=Y'   /* Wait for prompt.exe to complete */

/* modify the first word in the following to the location of prompt.exe in your system */

'g:\f\prompt.exe' registryValue || tab || noteText || tab || caption

if rc = 0 then
  say value( 'HKLM\Software\Kilowatt Software\Prompt[Response]', , 'Registry' )

