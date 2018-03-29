/* DatePick.rex
 demonstration program that uses DATEPICK.EXE

 usage:
  r4 DatePick [yyyymmdd[-hhmm] [subkey]] 

 examples:

  1. r4 DatePick		[ default date is TODAY ]

  2. r4 DatePick 20010707	[ use date 20010707 ]

  3. r4 DatePick 20010707-1315 [ use date 20010707 time 13:15 (1:15pm) ]

 refer to DATEPICK.HTM for a description of the usage of DATEPICK.EXE
*/

trace off /* ignore Cancel button error */

showDate = '-' /* => default date is TODAY */

showTime = '' /* => default time is 00:00 (midnight) */

subkey = ''

if arg(1) <> '' then do
  showDate = word( arg(1), 1 )
  if pos( '-', showDate ) > 0 then
    parse var showDate showDate '-' showTime
  subkey = '\'word( arg(1), 2 )
  end

'DatePick' showDate || copies( '-'showTime, showTime <> '' ) subkey

if rc = 0 then do
  response = value( 'HKLM\Software\Kilowatt Software\DatePick' || subkey || '[Response]', , 'Registry' )
  parse var response year +4 month +2 day '-' hour +2 minute
  say 'You selected:' hour':'minute 'on' month'/'day'/'year
  end

