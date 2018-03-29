/* roman.rex
 roman numeral computation

 usage:
  r4 roman nnnn

 where:
  nnnn is a year between 1 and 3000

 examples:
  r4 roman 2001		[shows: MMI]
  r4 roman 1999		[shows: MCMXCIX]

 tbd: future improvement, n > 3000 implies put horizontal bar over 1000 digits
*/

	/* get date argument TWICE
	 *  'original_date' is shown at end
	 *  'date' is adjusted within the loop downwards
	 */

arg original_date . 1 date .

	/* validate date argument */

if date = '' then
  call usagemsg 

if \ datatype( date, 'W' ) then
  call usagemsg 'The date must be a whole number'

if \ range( date, 1, 3000 ) then
  call usagemsg 'The date must be between 1 and 3000'

	/* progressively prepare the roman numeral of this date */

roman_date = ''

	/* add M's -- millenia */

do while date >= 1000
  roman_date = roman_date'M'
  date = date - 1000
  end

	/* add CM -- 900 years */

if date >= 900 then do
  roman_date = roman_date'CM'
  date = date - 900
  end

	/* add D -- 500 years */

if date >= 500 then do
  roman_date = roman_date'D'
  date = date - 500
  end

	/* add CD -- 400 years */

if date >= 400 then do
  roman_date = roman_date'CD'
  date = date - 400
  end

	/* add C's -- 100 years */

do while date >= 100
  roman_date = roman_date'C'
  date = date - 100
  end

	/* add XC -- 90 years */

if date >= 90 then do
  roman_date = roman_date'XC'
  date = date - 90
  end

	/* add L -- 50 years */

if date >= 50 then do
  roman_date = roman_date'L'
  date = date - 50
  end

	/* add XL -- 40 years */

if date >= 40 then do
  roman_date = roman_date'XL'
  date = date - 40
  end

	/* add X's -- 10 years */

do while date >= 10
  roman_date = roman_date'X'
  date = date - 10
  end

	/* add IX -- 9 years */

if date >= 9 then do
  roman_date = roman_date'IX'
  date = date - 9
  end

	/* add V -- 5 years */

if date >= 5 then do
  roman_date = roman_date'V'
  date = date - 5
  end

	/* add IV -- 4 years */

if date >= 4 then do
  roman_date = roman_date'IV'
  date = date - 4
  end

	/* add I's -- years */

do while date >= 1
  roman_date = roman_date'I'
  date = date - 1
  end

say original_date 'is' roman_date

exit 0

	/* RANGE procedure
	 * validates range of argument
	 */

range : procedure
  parse arg n, lo, hi
  return n >= lo & n <= hi

	/* USAGEMSG procedure
	 * shows program usage information
	 */

usagemsg :
  if arg( 1, 'E' ) then
    call lineout !, arg( 1 )
  call lineout !, 'Usage'
  call lineout !, " r4 roman nnnn [range 'nnnn': 1-3000]"
  exit 1
