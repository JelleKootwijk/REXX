/* execioTest.rex
 reverse lines in file
*/

parse arg infile ' , ' outfile 

if stream( outfile, 'C', 'Exists' ) then do
  call lineout !, 'File' outfile 'already exists.' ,
    'Do you want to erase it ? (Y|N)'
  if translate( left( linein( ! ), 1 ) ) <> 'Y' then do
    call lineout !, 'Exiting. File' outfile 'has not been changed.'
    exit 1
    end
  'erase' outfile
  end
 
'alloc f(INDD)  da('infile') shr'
'alloc f(OUTDD) da('outfile') old'

if 1 then do
  'execio * diskr INDD (LIFO OPEN FINIS'
 
  'execio * diskw OUTDD (OPEN FINIS' /* write queued lines to OUTDD */
  end

else do
 
  'execio * diskr INDD (STEM stem. OPEN FINIS'
 
  'execio * diskw OUTDD (STEM stem. OPEN FINIS' /* write queued lines to OUTDD */

  end
 
'free f(OUTDD)'
'free f(INDD)'

'type' outfile

exit 0
