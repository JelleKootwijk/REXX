/* dateStandard2dateOther.rex -- EXTERNAL PROCEDURE
 converts an ISO standard date: YYYYMMDD to a 'date' in various formats

 usage:
  dateString = dateStandard2dateOther( dateStandard, dateFormatString )

 error codes:
  -1 ==> invalid #arguments
  -3 ==> invalid date format string
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

 character case is not significant in the 'dateFormatString'

 English month names & abbreviations are used -- modify to another language

 ...test cases follow:

  say dateStandard2dateOther( '20050427', 'YYMMDD' )        '--> 050427'
  say dateStandard2dateOther( '20050427', 'YYYYMMDD' )      '--> 20050427'
  say dateStandard2dateOther( '20050427', 'MMDDYY' )        '--> 042705'
  say dateStandard2dateOther( '20050427', 'MMDDYYYY' )      '--> 04272005' 
  say dateStandard2dateOther( '20050427', 'DDMMYY' )        '--> 270405' 
  say dateStandard2dateOther( '20050427', 'DDMMYYYY' )      '--> 27042005' 
  say dateStandard2dateOther( '20050427', 'MM-DD-YY' )      '--> 04-27-05' 
  say dateStandard2dateOther( '20050427', 'MM-DD-YYYY' )    '--> 04-27-2005' 
  say dateStandard2dateOther( '20050427', 'DD-MM-YY' )      '--> 27-04-05' 
  say dateStandard2dateOther( '20050427', 'DD-MM-YYYY' )    '--> 27-04-2005' 
  say dateStandard2dateOther( '20050427', 'YY-MM-DD' )      '--> 05-04-27' 
  say dateStandard2dateOther( '20050427', 'YYYY-MM-DD' )    '--> 2005-04-27' 
  say dateStandard2dateOther( '20050427', 'MONTH DD, YY' )  '--> April 27, 05' 
  say dateStandard2dateOther( '20050427', 'MONTH-DD-YYYY' ) '--> April-27-2005' 
  say dateStandard2dateOther( '20050427', 'DD MONTH YY' )   '--> 27 April 05' 
  say dateStandard2dateOther( '20050427', 'DD MONTH YYYY' ) '--> 27 April 2005' 
  say dateStandard2dateOther( '20050427', 'MON.DD.YY' )     '--> Apr.27.05' 
  say dateStandard2dateOther( '20050427', 'MON.DD.YYYY' )   '--> Apr.27.2005'
  say dateStandard2dateOther( '20050427', 'DD/MON/YY' )     '--> 27/Apr/05'
  say dateStandard2dateOther( '20050427', 'DD/MON/YYYY' )   '--> 27/Apr/2005' 
*/

  if arg() <> 2 then
    return -1

  yearCutoff = 30

  monthNames = 'January February March April May June July August September October November December' 

  monthAbbr  = 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec' 
  
  parse UPPER ARG standardDate 1 y +4 m +2 d, inDateFormatString

  if words( standardDate ) <> 1 then
    return -1

  if \ datatype( standardDate, 'W' ) then
    return -1

  if length( standardDate ) <> 8 then
    return -1

  m = m + 0

  d = d + 0

  if \ range( m, 1, 12 ) then
    return -7

  days_in_month = ,
    word( '31 28 31 30 31 30 31 31 30 31 30 31', m ) ,
  + ( leap( y ) & m = 2 )

  if \ range( d, 1, days_in_month ) then 
    return -8

  if y < 1 then
    return -9

  dateFormatString = space( inDateFormatString )

  separators = ' ,-:/\|^#!.'

  dateFormatString = translate( dateFormatString, ' ', separators, ' ' )

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

  /* determine output separators -- sep1 and sep2 */

  parse value with sep1 sep2 /* default separators are the empty string */

  if words( dateFormatString ) = 3 then do

    parse var dateFormatString w1 w2 w3 .

    bef2 = length( w1 ) + 1

    pos2 = pos( w2, inDateFormatString )

    bef3 = pos2 + length( w2 )

    pos3 = pos( w3, inDateFormatString )

    parse var inDateFormatString ,
      =(bef2) sep1 =(pos2) =(bef3) sep2 =(pos3)

    /* empty separators must have been spaces */

    if sep1 = '' then
    sep1 = ' '

    if sep2 = '' then
    sep2 = ' '

    end
    
  signal value formatLabel
   
YYMMDD :
YY_MM_DD :

  return right2( y ) || sep1 || right2( m ) || sep2 || right2( d )
  
YYYYMMDD :
YYYY_MM_DD :

  return right4( y ) || sep1 || right2( m ) || sep2 || right2( d )

MMDDYY :
MM_DD_YY :

  return right2( m ) || sep1 || right2( d ) || sep2 || right2( y )

MMDDYYYY :
MM_DD_YYYY :

  return right2( m ) || sep1 || right2( d ) || sep2 || right4( y )

DDMMYY :
DD_MM_YY :

  return right2( d ) || sep1 || right2( m ) || sep2 || right2( y )

DDMMYYYY :
DD_MM_YYYY :

  return right2( d ) || sep1 || right2( m ) || sep2 || right4( y )

MONTH_DD_YY :

  return word( monthNames, m ) || sep1 || d || sep2 || right2( y )

MONTH_DD_YYYY :

  return word( monthNames, m ) || sep1 || d || sep2 || right4( y )

DD_MONTH_YY :

  return d || sep1 || word( monthNames, m ) || sep2 || right2( y )

DD_MONTH_YYYY :

  return d || sep1 || word( monthNames, m ) || sep2 || right4( y )

MON_DD_YY :

  return word( monthAbbr, m ) || sep1 || d || sep2 || right2( y )

MON_DD_YYYY :

  return word( monthAbbr, m ) || sep1 || d || sep2 || right4( y )

DD_MON_YY :

  return d || sep1 || word( monthAbbr, m ) || sep2 || right2( y )

DD_MON_YYYY :

  return d || sep1 || word( monthAbbr, m ) || sep2 || right4( y )
  
leap : procedure
  arg yr
  return (yr//4 = 0) & ((yr//100 <> 0) | (yr//400 = 0)) /* after Pope Gregory */ 

range : procedure
  return arg(1) >= arg(2) & arg(1) <= arg(3)

right2 : /* procedure */
  return right( arg(1), 2, '0' )

right4 : /* procedure */
  return right( arg(1), 4, '0' )
