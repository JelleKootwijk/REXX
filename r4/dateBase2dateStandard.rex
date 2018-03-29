/* dateBase2dateStandard.rex -- EXTERNAL PROCEDURE or MAIN PROGRAM
 prepares the 'Standard' date that is equivalent to a specific 'Base' date

 Usage:
  r4 dateBase2dateStandard 726340
  
 Shows:
  baseDate 726340 --> dateStandard 19890827 

 Or,
  standardDate = dateBase2dateStandard( 726340 )

 Sets:
  standardDate = '19890827'

 Note:
  negative values are returned if the argument is invalid
*/

  arg baseDate 1 dayNumber

  /* validate base date argument -- caller should provide correct value */

  if words( baseDate ) <> 1 then
    return -1

  if \ datatype( baseDate, 'W' ) then
    return -2

  if baseDate < 0 then
    return -3

  days_in_4_years     = 1461

  days_in_century     = 36524

  days_in_4_centuries = 146097  

  n_4_centuries = dayNumber % days_in_4_centuries

  dayNumber = dayNumber // days_in_4_centuries

  n_centuries = dayNumber % days_in_century

  if n_centuries = 4 then
    n_centuries = 3

  dayNumber = dayNumber // days_in_century

  n_4_years = dayNumber % days_in_4_years

  dayNumber = dayNumber // days_in_4_years

  n_year = dayNumber % 365

  if n_year = 4 then
    n_year = 3

  y = n_year + ( 4 * n_4_years ) + ( 100 * n_centuries ) + ( 400 * n_4_centuries ) + 1

  if leap( y ) then
    monthBase = '0 31 60 91 121 152 182 213 244 274 305 335'
  else
    monthBase = '0 31 59 90 120 151 181 212 243 273 304 334'

  dayNumber = dayNumber - ( 365 * n_year )

  do i=1 to 12
    if dayNumber < word( monthBase, i ) then
      leave i

    m = i

    end i

  dayNumber = dayNumber - word( monthBase, m ) + 1

  dateStandard = right( y, 4, '0' ) || right( m, 2, '0' ) || right( dayNumber, 2, '0' )

  parse source . invocation .

  if invocation = 'COMMAND' then
    say 'baseDate' baseDate '--> dateStandard' dateStandard 

  return dateStandard
  
leap : procedure
  arg yr
  return (yr//4 = 0) & ((yr//100 <> 0) | (yr//400 = 0)) /* after Pope Gregory */ 
   
