/* dateStandard2dateBase.rex -- EXTERNAL PROCEDURE or MAIN PROGRAM
 prepares the 'Base' date that is equivalent to a specific 'Standard' date

 Usage:
  r4 dateStandard2dateBase 19890827
  
 Shows:
  dateStandard 19890827 --> baseDate 726340 

 Or,
  baseDate = dateStandard2dateBase( 19890827 )

 Sets:
  baseDate = '726340'

 Note:
  negative values are returned if the argument is invalid
*/

  arg standardDate

  /* validate standard date argument -- caller should provide correct value */

  if words( standardDate ) <> 1 then
    return -1

  if \ datatype( standardDate, 'W' ) then
    return -2

  if length( standardDate ) <> 8 then
    return -3

  parse var standardDate y +4 m +2 d

  if y < 1 then
    return -4

  m = m + 0

  d = d + 0

  if \ range( m, 1, 12 ) then
    return -4

  days_in_month = ,
    word( '31 28 31 30 31 30 31 31 30 31 30 31', m ) ,
	+ ( leap( y ) & m = 2 )

  if \ range( d, 1, days_in_month ) then 
    return -5

  days_in_4_years     = 1461

  days_in_century     = 36524

  days_in_4_centuries = 146097  

  thisYear0 = y - 1

  nQuadCenturies = thisYear0 % 400
  
  thisYear0 = thisYear0 - ( 400 * nQuadCenturies )
  
  nCenturies = thisYear0 % 100
  
  thisYear0 = thisYear0 - ( 100 * nCenturies )
  
  nQuadYears = thisYear0 % 4
  
  thisYear0 = thisYear0 - ( 4 * nQuadYears )

  baseDate = ,
  	  ( nQuadCenturies * days_in_4_centuries ) ,
  	+ ( nCenturies * days_in_century ) ,
  	+ ( nQuadYears * days_in_4_years ) ,
  	+ ( thisYear0 * 365 ) ,
  	+ julianDay( m, d, y ) ,
	- 1

  parse source . invocation .

  if invocation = 'COMMAND' then
    say 'dateStandard' standardDate '--> baseDate' baseDate  

  return baseDate
  
julianDay : procedure

  arg m, d, y

  if leap( y ) then
    monthBase = '0 31 60 91 121 152 182 213 244 274 305 335'
  else
    monthBase = '0 31 59 90 120 151 181 212 243 273 304 334'

  return word( monthBase, m ) + d
  
leap : procedure
  arg yr
  return (yr//4 = 0) & ((yr//100 <> 0) | (yr//400 = 0)) /* after Pope Gregory */ 

range : procedure
  return arg(1) >= arg(2) & arg(1) <= arg(3)
