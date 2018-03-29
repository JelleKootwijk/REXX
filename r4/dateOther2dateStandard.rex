/* dateOther2dateStandard.rex -- EXTERNAL PROCEDURE
 converts a 'date' in various formats to an ISO standard date: YYYYMMDD

 usage:
  dateStandard = dateOther2dateStandard( dateString, dateFormatString )

 error codes:
  -1 ==> invalid #arguments
  -2 ==> #words in date string does not match #words in date format string
  -3 ==> unknown date format string
  -4 ==> date string does not match type of date format
  -5 ==> unknown month name
  -6 ==> unknown month abbreviation
  -7 ==> invalid month numeric value
  -8 ==> invalid day numeric value
  -9 ==> invalid year numeric value

 supported dateFormatStrings:
  YYMMDD
  YYYYMMDD
  MMDDYY
  MMDDYYYY
  DDMMYY
  DDMMYYYY
  MM (sep) DD (sep) YY
  MM (sep) DD (sep) YYYY
  DD (sep) MM (sep) YY
  DD (sep) MM (sep) YYYY
  YY (sep) MM (sep) DD
  YYYY (sep) MM (sep) DD
  Month (sep) DD (sep) YY
  Month (sep) DD (sep) YYYY
  DD (sep) Month (sep) YY
  DD (sep) Month (sep) YYYY
  Mon (sep) DD (sep) YY
  Mon (sep) DD (sep) YYYY
  DD (sep) Mon (sep) YY
  DD (sep) Mon (sep) YYYY

 separator characters can be any of:
  (space)
  ,
  -
  :
  /
  \
  |
  ^
  #
  !
  .

 different separators can be used in the dateString and the dateFormatString,
 but the number of terms must agree. for example,
  27/04/05 matches format dd-mm-yy

 if the dateString contains a two-digit year value >= 30, then the
 resulting year value will have a leading 19. you can modify the 'yearCutoff'
 value to establish a different limit.
 
 example,
   27-04-35 (format: dd-mm-yy)
 becomes:
   19350427

 whereas:
   27-04-05 (format: dd-mm-yy)
 becomes:
   20050427

 English month names & abbreviations are used -- modify to another language

 ...test cases follow:

  say dateOther2dateStandard( "050427", 'YYMMDD' )
  say dateOther2dateStandard( "20050427", 'YYYYMMDD' )
  say dateOther2dateStandard( "042705", 'MMDDYY' )
  say dateOther2dateStandard( "04272005", 'MMDDYYYY' )
  say dateOther2dateStandard( "270405", 'DDMMYY' )
  say dateOther2dateStandard( "27042005", 'DDMMYYYY' )
  say dateOther2dateStandard( "04-27-05", 'MM-DD-YY' )
  say dateOther2dateStandard( "04-27-2005", 'MM-DD-YYYY' )
  say dateOther2dateStandard( "27-04-05", 'DD-MM-YY' )
  say dateOther2dateStandard( "27-04-2005", 'DD-MM-YYYY' )
  say dateOther2dateStandard( "05-04-27", 'YY-MM-DD' )
  say dateOther2dateStandard( "2005-04-27", 'YYYY-MM-DD' )
  say dateOther2dateStandard( "April 27 05", 'MONTH-DD-YY' )
  say dateOther2dateStandard( "April 27 2005", 'MONTH-DD-YYYY' )
  say dateOther2dateStandard( "27 April 05", 'DD-MONTH-YY' )
  say dateOther2dateStandard( "27 April 2005", 'DD-MONTH-YYYY' )
  say dateOther2dateStandard( "Apr-27-05", 'MON-DD-YY' )
  say dateOther2dateStandard( "Apr-27-2005", 'MON-DD-YYYY' )
  say dateOther2dateStandard( "27-Apr-05", 'DD-MON-YY' )
  say dateOther2dateStandard( "27-Apr-2005", 'DD-MON-YYYY' )
*/

  if arg() <> 2 then
    return -1

  yearCutoff = 30

  monthNames = 'JANUARY FEBRUARY MARCH APRIL MAY JUNE JULY AUGUST SEPTEMBER OCTOBER NOVEMBER DECEMBER' 

  monthAbbr  = 'JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC' 
  
  parse UPPER ARG dateString, dateFormatString

  dateString = space( dateString )

  dateFormatString = space( dateFormatString )

  separators = ' ,-:/\|^#!.'

  dateString = translate( dateString, ' ', separators, ' ' )

  dateFormatString = translate( dateFormatString, ' ', separators, ' ' )

  if words( dateString ) <> words( dateFormatString ) then
    return -2

  formatLabel = translate( space( dateFormatString ), '_', ' ' )

  supportedFormats = ,
    'YYMMDD' ,
    'YYYYMMDD' ,
    'MMDDYY' ,
    'MMDDYYYY' ,
    'DDMMYY' ,
    'DDMMYYYY' ,
    'MM_DD_YY' ,
    'MM_DD_YYYY' ,
    'DD_MM_YY' ,
    'DD_MM_YYYY' ,
    'YY_MM_DD' ,
    'YYYY_MM_DD' ,
    'MONTH_DD_YY' ,
    'MONTH_DD_YYYY' ,
    'DD_MONTH_YY' ,
    'DD_MONTH_YYYY' ,
    'MON_DD_YY' ,
    'MON_DD_YYYY' ,
    'DD_MON_YY' ,
    'DD_MON_YYYY'

  if wordpos( formatLabel, supportedFormats ) = 0 then
    return -3
    
  signal value formatLabel
   
YYMMDD :

  if \ datatype( dateString, 'W' ) ,
   | length( dateString ) <> 6 ,
   | dateString < '010101' then
    return -4 

  parse var dateString y +2 m +2 d

  return standard2()
  
YYYYMMDD :

  if \ datatype( dateString, 'W' ) ,
   | length( dateString ) <> 8 ,
   | dateString < '00010101' then
    return -4 

  parse var dateString y +4 m +2 d

  return standard4()

MMDDYY :

  if \ datatype( dateString, 'W' ) ,
   | length( dateString ) <> 6 then
    return -4 

  parse var dateString m +2 d +2 y

  return standard2()

MMDDYYYY :

  if \ datatype( dateString, 'W' ) ,
   | length( dateString ) <> 8 then
    return -4 

  parse var dateString m +2 d +2 y

  return standard4()

DDMMYY :

  if \ datatype( dateString, 'W' ) ,
   | length( dateString ) <> 6 then
    return -4 

  parse var dateString d +2 m +2 y

  return standard2()

DDMMYYYY :

  if \ datatype( dateString, 'W' ) ,
   | length( dateString ) <> 8 then
    return -4 

  parse var dateString d +2 m +2 y

  return standard4()

MM_DD_YY :

  parse var dateString m d y

  if length( y ) > 2 then
    return -9 

  return standard2()

MM_DD_YYYY :

  parse var dateString m d y

  if length( y ) > 4 then
    return -9 

  return standard4()

DD_MM_YY :

  parse var dateString d m y

  if length( y ) > 2 then
    return -9 

  return standard2()

DD_MM_YYYY :

  parse var dateString d m y

  if length( y ) > 4 then
    return -9 

  return standard4()

YY_MM_DD :

  parse var dateString y m d

  if length( y ) > 2 then
    return -9 

  return standard2()

YYYY_MM_DD :

  parse var dateString y m d

  if length( y ) > 4 then
    return -9 

  return standard4()

MONTH_DD_YY :

  parse var dateString month d y

  if length( y ) > 2 then
    return -9 

  m = wordpos( month, monthNames )

  if m = 0 then
    return -5

  return standard2()

MONTH_DD_YYYY :

  parse var dateString month d y

  if length( y ) > 4 then
    return -9 

  m = wordpos( month, monthNames )

  if m = 0 then
    return -5

  return standard4()

DD_MONTH_YY :

  parse var dateString d month y

  if length( y ) > 2 then
    return -9 

  m = wordpos( month, monthNames )

  if m = 0 then
    return -5

  return standard2()

DD_MONTH_YYYY :

  parse var dateString d month y

  if length( y ) > 4 then
    return -9 

  m = wordpos( month, monthNames )

  if m = 0 then
    return -5

  return standard4()

MON_DD_YY :

  parse var dateString mon d y

  if length( y ) > 2 then
    return -9 

  m = wordpos( mon, monthAbbr )

  if m = 0 then
    return -5

  return standard2()

MON_DD_YYYY :

  parse var dateString mon d y

  if length( y ) > 4 then
    return -9 

  m = wordpos( mon, monthAbbr )

  if m = 0 then
    return -5

  return standard4()

DD_MON_YY :

  parse var dateString d mon y

  if length( y ) > 2 then
    return -9 

  m = wordpos( mon, monthAbbr )

  if m = 0 then
    return -5

  return standard2()

DD_MON_YYYY :

  parse var dateString d mon y

  if length( y ) > 4 then
    return -9 

  m = wordpos( mon, monthAbbr )

  if m = 0 then
    return -5

  return standard4()
  
leap : procedure
  arg yr
  return (yr//4 = 0) & ((yr//100 <> 0) | (yr//400 = 0)) /* after Pope Gregory */ 

range : procedure
  return arg(1) >= arg(2) & arg(1) <= arg(3)

right2 : /* procedure */
  return right( arg(1), 2, '0' )

right4 : /* procedure */
  return right( arg(1), 4, '0' )
  
standard2 : /* procedure */

  cc = validateMonthAndDay()

  if cc < 0 then
    return cc

  return ,
    word( '19 20', 1 + ( y < yearCutoff ) ) || right2( y ) || right2( m ) || right2( d )
  
standard4 : /* procedure */

  cc = validateMonthAndDay()

  if cc < 0 then
    return cc

  return right4( y ) || right2( m ) || right2( d )

validateMonthAndDay : /* procedure */

  if \ range( m, 1, 12 ) then
    return -7

  days_in_month = ,
    word( '31 28 31 30 31 30 31 31 30 31 30 31', m ) ,
  + ( leap( y ) & m = 2 )

  if \ range( d, 1, days_in_month ) then 
    return -8

  return 0
