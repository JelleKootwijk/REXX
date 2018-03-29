/* rev2html.rex
  finish revision of lines in directory listing

  assume input lines have the following format:
   2001/07/27 23:01     1237 abc.dat

  usage:
    r4 rev < dirinfo.txt | fsort /d | r4 rev2html > __readme.htm
*/

say '<html>'
say '<head>'
say '<title>Index of latest revisions</title>'
say '<link rel=stylesheet type="text/css" HREF="kwsw.css">'
say '</head>'
say '<body background=backgrnd.gif>'
say '<center>'
say '<a href="../default.htm"><img src=kwsNewLogo2.gif border=0></a>'
say '<br><a href="mailto:support@kilowattsoftware.com">e-mail: support@kilowattsoftware.com</a>'
say '<p'
say '<p>This is a listing of the files that have been added'
say '<br>to the <b>latest</b> directory'
say '<br>in reverse chronological order.'
say '<p>'
say '<p>You can click on the file name to download it !'
say '<p>'
say "<p>Or, you can right click on the file and select 'Save As...'"
say '<p>'
say '<table cellspacing=5 border=1>'
say '<tr><th>Date</th><th>Time</th><th>Size</th><th>File<tr>'

do lines()

  parse linein date time size file

  say '<tr><td>'date'</td><td>'time'</td><td align=right>'size'</td><td><a href='file'>'file'</a><tr>'

  end

say '</table>'
say '</center>'
say '</body>'
say '</html>'  