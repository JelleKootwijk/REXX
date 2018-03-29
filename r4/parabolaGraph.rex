/* parabolaGraph.rex
 this program prepares the graph of a parabola

 it uses the Poof!(TM) program named GraphIt
*/

parse arg xLimit yLimit .

if \ datatype( xLimit, 'W' ) then
  xLimit = 100

if \ datatype( yLimit, 'W' ) then
  yLimit = 100

parse value 1 1 with xOrigin yOrigin

graphPropsFile = 'parabolaGraph.props'

'erase' graphPropsFile

/* prepare the graph properties */

call lineout graphPropsFile, '# parabolaGraph.props -- created by program: parabolaGraph.rex'
call lineout graphPropsFile, 'quadrants=4'
call lineout graphPropsFile, 'bgColor=gainsboro'
call lineout graphPropsFile, 'fgColor=mediumblue'
call lineout graphPropsFile, 'textColor=blue'
call lineout graphPropsFile, 'lineWidth=3'
call lineout graphPropsFile, 'insideColor=lightskyblue'
call lineout graphPropsFile, 'gridColor=lightgoldenrodyellow'
call lineout graphPropsFile, 'xOrigin='xOrigin
call lineout graphPropsFile, 'yOrigin='yOrigin
call lineout graphPropsFile, 'xLimit='xLimit
call lineout graphPropsFile, 'yLimit='yLimit
call lineout graphPropsFile, 'fontName=sansserif'
call lineout graphPropsFile, '# fontStyle=bold'
call lineout graphPropsFile, 'fontSize=12'
call lineout graphPropsFile, 'xCaption=X^2 : -'xLimit '..' xLimit
call lineout graphPropsFile, 'yCaption=Y limit :' yLimit

/* add the parabola points */

call charout graphPropsFile, 'pointSet='

do i=-10 to 10 by .1
  call charout graphPropsFile, i',' || (i*i) || ';'
  end

call lineout graphPropsFile, ''

call lineout graphPropsFile /* close the file */

/* display the graph using the Poof!(TM) program named GraphIt */

'graphit' graphPropsFile
