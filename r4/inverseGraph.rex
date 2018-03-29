/* inverseGraph.rex
 this program prepares the graph of the inverse of X

 it uses the Poof!(TM) program named GraphIt
*/

xLimit = 2

yLimit = 10

graphPropsFile = 'inverseGraph.props'

'erase' graphPropsFile

/* prepare the graph properties */

call lineout graphPropsFile, '# inverseGraph.props -- created by program: inverseGraph.rex'
call lineout graphPropsFile, 'quadrants=4'
call lineout graphPropsFile, 'bgColor=gainsboro'
call lineout graphPropsFile, 'fgColor=mediumblue'
call lineout graphPropsFile, 'textColor=blue'
call lineout graphPropsFile, 'lineWidth=3'
call lineout graphPropsFile, 'insideColor=lightskyblue'
call lineout graphPropsFile, 'gridColor=lightgoldenrodyellow'
call lineout graphPropsFile, 'xLimit='xLimit
call lineout graphPropsFile, 'yLimit='yLimit
call lineout graphPropsFile, 'fontName=sansserif'
call lineout graphPropsFile, '# fontStyle=bold'
call lineout graphPropsFile, 'fontSize=12'
call lineout graphPropsFile, 'xCaption=1 / X : -'xLimit '..' xLimit
call lineout graphPropsFile, 'yCaption=Y limit :' yLimit

/* add the points */

call charout graphPropsFile, 'pointSet='

do i=-xLimit to xLimit by .01
  if i <> 0 then
    call charout graphPropsFile, i',' || (  1 / i ) || ';'
  end

call lineout graphPropsFile, ''

call lineout graphPropsFile /* close the file */

/* display the graph using the Poof!(TM) program named GraphIt */

'graphit' graphPropsFile
