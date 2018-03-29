/* caldisp.rex, show calendar for current month, highlighting today's date

 Keywords
  Calendar display, Advanced string function examples

 Usage
  r4 caldisp

 Arguments
  None

 Files used
  Standard output

 Exit codes
   0   => always success
 non-0 => [never fails]

 Input record format
  N/A

 Sample input file
  N/A

 Sample output file
  ีออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
  ณ  8:15pm               September               89.267 ณ
  ณ                          1989                        ณ
  ณ  Sun     Mon     Tue     Wed     Thu     Fri     Sat ณ
  ณ                                            1       2 ณ
  ณ    3       4       5       6       7       8       9 ณ
  ณ   10      11      12      13      14      15      16 ณ
  ณ   17      18      19      20      21      22      23 ณ
  ณ > 24 <    25      26      27      28      29      30 ณ
  ิออออออออออออออออออออออออออออออออออออออออออออออออออออออพ

 Example of use
   r4 caldisp

 Explanation
  This procedure displays the calendar for the current month, with the
  current day highlighted.  
*/

daysin = "31 28 31 30 31 30 31 31 30 31 30 31"
days = "Monday Tuesday Wednesday Thursday Friday Saturday Sunday"

 /* get year, month, and day of month */
parse value date(standard) with yr 5 mon 7 dayofmon

 /* show title lines */
say right( time(civil), 8) center( date(month), 38 ),
  || substr( yr, 3 )"."right( date(dayofyear), 3, '0' )

say center( yr, 56 )

say "  Sun     Mon     Tue     Wed     Thu     Fri     Sat"

dayofwk = wordpos( date(weekday), days )    /* identify day of week: 1 to 7 */

day1no = 1 + ((dayofwk + (35 - dayofmon)) // 7) /* day# of 1st day of month */

daysinmo = word( daysin, mon )                   /* identify #days in month */

if leap( yr ) & (mon = 2) then          /* identify if this is a leap month */
  daysinmo = daysinmo + 1            /* february has 29 days in a leap year */ 

	/* prefix leading line with blanks */

call charout , left( " ", (day1no//7) * 8 )

do i=1 for daysinmo             /* show all day numbers within current month */

  if i = dayofmon then                   /* day "i" is today's day of month */
    call charout , center( "> "right( i, 2 )" <", 8 )    /* highlight today */
  else
    call charout , center( right( i, 2 ), 8 )

  if ((i+day1no) // 7) = 0 then                                 /* saturday */
    say                                                         /* end line */

  end

if ((i+day1no) // 7) <> 1 then              /* if last day was not saturday */
  say                                                           /* end line */

exit 0

	/* LEAP procedure
	 * identify if this year is a leap year (the year 2000 is not a leap year)
	 */

leap : procedure
  arg yr
  return (yr//4 = 0) & ((yr//100 <> 0) | (yr//400 = 0)) /* after Pope Gregory */

