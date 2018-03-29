/* picker.rex
 demonstration program that uses PICKLIST.EXE

 usage:
  r4 picker

 refer to PICKLIST.HTM for a description of the usage of PICKLIST.EXE
*/

caption = 'Pick a color'

choice.1 = 'Red'
choice.2 = 'Green'
choice.3 = 'Blue'

trace off /* ignore Cancel button error */

picklist caption','choice.1','choice.2','choice.3

if rc > 0 then
  say 'You picked:' choice.rc
else
  say 'You hit the Cancel button'
