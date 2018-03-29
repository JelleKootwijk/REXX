/* rev.rex
  revise lines in directory listing so they can be sorted chronologically

  assume input lines have the following format:
   07-27-01  11:01PM                 1237 abc.dat

  the resulting line will be
   2001/07/27 23:01     1237 abc.dat

  usage:
    r4 rev < dirinfo.rex | fsort /d | r4 rev2html > __readme.htm
*/

do lines()

  parse linein mon'-'day'-'yr hr':' +1 min +2 amOrPm size file

  if file = '__readme.htm' | file = 'kwsNewLogo2.gif' then
    iterate

  /* adjust year to four digit format */

  if yr > 90 then
    yr = yr + 1900
  else
    yr = yr + 2000

  /* adjust hour to 24 hour clock format */

  if amOrPm = 'PM' & hr <> 12 then
    hr = hr + 12

  /* emit sortable line */

  say yr'/'mon'/'day hr':'min right( size, 10 ) file

  end
