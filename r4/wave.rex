/* wave.rex
 uses WAVE.EXE (in Poof!) to play a Windows wave file

 this can be used in a SAY instruction, for example:
  say 'Finished' wave( 'TADA' ) /* plays the TADA.WAV file */
*/

ARG wavefile '.WAV'

'wave.exe' wavefile

return ''
