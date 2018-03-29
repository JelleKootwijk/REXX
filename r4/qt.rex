/* QT.rex
 This is the 'query time' example program from TRL-2 p172
 which tells the current time in English.

 usage:
  r4 qt [_ _ hh:mm:ss]
*/

	/* validate arguments */

parse arg parm . testtime .

select
  when parm='?' then
    call tell
  when parm='' then
    nop
  otherwise
    say 'only "?" is a valid argument to QT. The argument'
    say 'that you supplied ("'parm'") has been ignored.'
    call tell
  end

	/* establish time to display */

if testtime = '' then
  now = time()			/* show current time */
else
  now = testtime		/* show specific time */

	/* prepare nearby time clauses */

near.0 = ''
near.1 = ' just gone'
near.2 = ' just after'
near.3 = ' nearly'
near.4 = ' almost'

	/* get hour, minute, and second */

parse var now hour':'min':'sec

	/* round minutes */

if sec > 29 then
  min=min+1

	/* determine REMAINDER of minutes divided by 5 */

mod = min // 5

out = "It's"near.mod	/* begin with nearby time clause */

	/* round hour */

if min > 32 then
  hour = hour + 1

	/* increment minutes by nearby interval */

min = min + 2

	/* show noon or midnight */

if hour // 12 = 0 & min // 60 <= 4 then do
  if hour=12 then
    say out 'Noon.'
  else
    say out 'Midnight.'
  exit
  end

	/* reduce minutes to 5 minute interval base */

min = min - ( min // 5 )

if hour > 12 then
  hour = hour - 12		/* reduce PM times by 12 hours */
else if hour = 0 then
  hour = 12				/* midnight to one am */

	/* prepare 5 minute interval clauses */

select
  when min = 0  then nop
  when min = 60 then min = 0
  when min = 5  then out = out 'five past'
  when min = 10 then out = out 'ten past'
  when min = 15 then out = out 'a quarter past'
  when min = 20 then out = out 'twenty past'
  when min = 25 then out = out 'twenty-five past'
  when min = 30 then out = out 'half past'
  when min = 35 then out = out 'twenty-five to'
  when min = 40 then out = out 'twenty to'
  when min = 45 then out = out 'a quarter to'
  when min = 50 then out = out 'ten to'
  when min = 55 then out = out 'five to'
  end  

	/* hour numbers */

numbers = 'one two three four five six',
 'seven eight nine ten eleven twelve'

out = out word( numbers, hour )

if min = 0 then
  out = out "o'clock"	/* add exact hour clause */

say out'.'				/* show entire time clause */

exit

	/* TELL procedure
	 * shows usage information
	 */

tell:
  say 'Usage:'
  say '  r4 QT [_ _ hh:mm:ss]'
  say
  return