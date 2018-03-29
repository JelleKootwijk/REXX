/* anova.rex,  analyze variance of multiple columns of statistics
 Analyze the variance of multiple columns of statistics.
 Values within each column are related.
 The mean and standard deviation are computed for each column.

 Keywords
  Analysis of variance, computational mean, standard deviation

 Usage
  ex anova infile [>outfile]

 Arguments
  1. file containing values to analyze [required parameter]

 Files used
  infile
  Standard output

 Exit codes
   0   => all went well
 non-0 => usage error

 Input record format
  1st line contains single word column titles.
  Remaining lines are columnar values to analyze.

                     Sample input file -- see file: anova.in
                   +-----------------------------------------+
                   |    1999            2000            2001 | <Column Titles
                   |   102.0           228.0           358.0 |
                   |   297.0           277.0           317.0 |
                   |   151.0           377.0           371.0 |
                   |   273.0           387.0           499.0 |
                   |   256.0           280.0           509.0 |
                   |   348.0           426.0           544.0 |
                   |   248.0           446.0           520.0 |
                   |   182.0           292.0           545.0 |
                   |   238.0           360.0           404.0 |
                   |   286.0           336.0           458.0 |
                   |   284.0           293.0           519.0 |
                   |   331.0           289.0           311.0 |
                   +-----------------------------------------+

                                           Sample output file
  +----------------------------------------------------------+
  |                     1999            2000            2001 |
  |Mean           249.666667      332.583333          446.25 |
  |Std.Dev.       72.5300356      66.8736371       88.999617 |
  +----------------------------------------------------------+

 Example of use
  ex anova anova.in >outfile

 Explanation
  In the example above, input values within file "infile" are analyzed.
  Results are stored into "outfile".
*/

parse arg statfile .

if statfile = '' then
  signal usagemsg

nrows = 0
colsum. = 0

coltitles = linein( statfile )                        /* get column titles */

do while lines( statfile ) > 0
  values = linein( statfile )                    /* get line of statistics */
  if values = '' then iterate                        /* ignore empty lines */
  if nrows = 0 then
    cols = words( values )                /* initialize #columns per row */

  else if cols <> words( values ) /* assert all rows have uniform #columns */
    then do
      call lineout '!', ,
        'Erroneous #columns in line' nrows',' cols 'columns expected'
      call lineout '!', 'Erroneous line was:' values
      exit 1
      end

  do i=1 to cols                                    /* compute column sums */
    colsum.i = colsum.i + word( values, i )          /* augment column sum */
    end

  nrows = nrows + 1                      /* another row has been processed */
  end

 /* compute column means */
do i=1 to cols                                      /* process all columns */
  mean.i = colsum.i / nrows                         /* compute column mean */
  end

call lineout statfile                                    /* close statfile */

 /* process statistics again, to compute standard deviation */

devsum. = 0
coltitles = linein( statfile )                 /* get column titles, again */

do while lines( statfile ) > 0
  values = linein( statfile )
  if values = '' then iterate
  do i=1 to cols
    devsum.i = devsum.i + ((word( values, i ) - mean.i) ** 2)
    end
  end

colwidth = trunc( ( 79 - 9 ) / cols ) 

call charout , '         '

do i=1 to cols
  call charout , right( word( coltitles, i ), colwidth )
  end

say

call charout , 'Mean     '

do i=1 to cols
  call charout , right( mean.i, colwidth )     /* previously computed mean */
 end

say                                     /* conclude line identifying means */

call charout , 'Std.Dev. '
do i=1 to cols
  stddev.i = sqrt( devsum.i / ( nrows - 1 ) )    /* compute std. deviation */
  call charout , right( stddev.i, colwidth )
  end

say                                    /* conclude standard deviation line */

exit 0

sqrt : procedure
  arg n

  if n > 1 then
    stab = 9
  else
    stab = .9

  limit = '1e-' || ( digits() + 1 )

  do i=1 to 20 until abs( error ) < limit
    stab = (stab + ( n / stab)) / 2
    error = ( n - ( stab * stab ) ) / 2
    end

  return stab

usagemsg :
  call lineout '!', 'usage'
  call lineout '!', '  ex anova input_file  [ > outfile ]'
  exit 1
