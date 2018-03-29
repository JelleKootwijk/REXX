/* caldisp2.rex, show calendar for current month, FAST VERSION

 this is similar to caldisp.rex, but this is faster
 because loops were replaced by direct string overlays

 usage
   r4 caldisp2
*/

	/* get year, month, and day of month */

parse value date( "S" ) with year 5 month 7 dayofmon

dayofmon = strip( dayofmon, "L", "0" )	/* strip leading zero */

	/* show title lines */

say right( time("C"), 8) center( date("M"), 38 ) ,
  substr( year, 3 )"."right( date("D"), 3, '0' )

say center( year, 56 )

say "  Sun     Mon     Tue     Wed     Thu     Fri     Sat"

	/* compute day of week: 1 to 7 */

dayofwk = 1 + ( date("B") // 7 )

	/* identify #days in month */

daysinmo = word( "31 28 31 30 31 30 31 31 30 31 30 31", month )

	/* add 1 to #days in month if this is a leap year */

if month = 2 then
  daysinmo = daysinmo + leap( year )

	/* compute day# of 1st day of month */

day1no = 1 + ((35 + dayofwk - dayofmon) // 7 )

	/* prefix leading line with blanks */

vector = left( " ", 8 * day1no )                           || ,
         overlay( " > "right( dayofmon, 2 )" < " ,            ,
	     left(  "    1       2       3       4       5   " || ,
                "    6       7       8       9      10   " || ,
                "   11      12      13      14      15   " || ,
                "   16      17      18      19      20   " || ,
                "   21      22      23      24      25   " || ,
                "   26      27      28      29      30   " || ,
                "   31   ", (daysinmo * 8) ),                 ,
		    1 + ((dayofmon-1) * 8) )

	/* show calendar lines */

do i=1 to length( vector ) by 56
  say substr( vector, i, 56 )
  end

exit

leap : procedure
  arg yr
  return (yr//4 = 0) & ((yr//100 <> 0) | (yr//400 = 0))


