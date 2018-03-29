/* squareRootGraph.rex
 this program prepares the graph of the squareRoot of X

 it uses the Poof!(TM) program named GraphIt
*/

xLimit = 5

yLimit = 5

graphPropsFile = 'squareRootGraph.props'

'erase' graphPropsFile

/* prepare the graph properties */

call lineout graphPropsFile, '# squareRootGraph.props -- created by program: squareRootGraph.rex'
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
call lineout graphPropsFile, 'xCaption=1 / X : 0 ..' xLimit
call lineout graphPropsFile, 'yCaption=Y limit :' yLimit

/* add the points */

call charout graphPropsFile, 'pointSet='

do i=.01 to 1 by .01
  if i <> 0 then
    call charout graphPropsFile, i',' || squareroot( i ) || ';'
  end

do i=1.01 to xLimit by .1
  if i <> 0 then
    call charout graphPropsFile, i',' || squareroot( i ) || ';'
  end

call lineout graphPropsFile, ''

call lineout graphPropsFile /* close the file */

/* display the graph using the Poof!(TM) program named GraphIt */

'graphit' graphPropsFile
