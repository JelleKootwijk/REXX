/* dateCalc.rex -- EXTERNAL PROCEDURE
 calculates a 'date' that is a number of days before or after another date

 various date formats are accepted

 usage:
  calculatedDate = dateCalc( dateString, dateFormatString, increment )

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
*/

  if arg() <> 3 then
    return -1
  
  parse arg dateString, dateFormatString, increment

  if \ datatype( increment, 'W' ) then
    return -1

  standardDate = dateOther2dateStandard( dateString, dateFormatString )

  if standardDate < '00010101' then
    return standardDate 

  baseDate = dateStandard2dateBase( standardDate )

  baseDate = baseDate + increment

  standardDate = dateBase2dateStandard( baseDate )

  return dateStandard2dateOther( standardDate, dateFormatString )
