/* anova2.rex,  analyze variance of multiple columns of statistics, detailed
 Analyze the variance of multiple columns of statistics.
 Values within each column are related.
 The mean and standard deviation are computed for each column.
 Detailed analyses between columns is also performed.

 Keywords
  Analysis of variance, computational mean, standard deviation

 Usage
  ex anova2 statfile [>outfile]

 Arguments
  1. file containing values to analyze [required parameter]

 Files used
  statfile
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
  +----------------------------------------------------------------------------+
  |        102.0       228.0       358.0                                       |
  |        297.0       277.0       317.0                                       |
  |        151.0       377.0       371.0                                       |
  |        273.0       387.0       499.0                                       |
  |        256.0       280.0       509.0                                       |
  |        348.0       426.0       544.0                                       |
  |        248.0       446.0       520.0                                       |
  |        182.0       292.0       545.0                                       |
  |        238.0       360.0       404.0                                       |
  |        286.0       336.0       458.0                                       |
  |        284.0       293.0       519.0                                       |
  |        331.0       289.0       311.0                                       |
  |                                                                            |
  | Column 1999 : total 2996.0, mean: 249.666667                               |
  | Column 2000 : total 3991.0, mean: 332.583333                               |
  | Column 2001 : total 5355.0, mean: 446.25                                   |
  |                                                                            |
  | Grand total 12342.0, grand mean: 342.833333                                |
  |                                                                            |
  | Subject deviation column 1999 : -93.166666                                 |
  | Subject deviation column 2000 : -10.250000                                 |
  | Subject deviation column 2001 : 103.416667                                 |
  |                                                                            |
  | Between group sum of squares : 233761.166                                  |
  |                                                                            |
  | Total sum of squares : 427951.000                                          |
  |                                                                            |
  | Column 1999                                                                |
  |   Within group sum of squares : 57866.6667                                 |
  |   Variance : 5260.60606                                                    |
  |   Std. dev. : 72.5300355                                                   |
  |                                                                            |
  | Column 2000                                                                |
  |   Within group sum of squares : 49192.9167                                 |
  |   Variance : 4472.08334                                                    |
  |   Std. dev. : 66.873637                                                    |
  |                                                                            |
  | Column 2001                                                                |
  |   Within group sum of squares : 87130.2500                                 |
  |   Variance : 7920.93182                                                    |
  |   Std. dev. : 88.999617                                                    |
  |                                                                            |
  | Total within group sum of squares : 194189.833                             |
  |                                                                            |
  | Sum of squared scores : 4659200.00                                         |
  |                                                                            |
  | Sum of column total squares : 53580122.0                                   |
  |                                                                            |
  | Grand total squared : 152324964                                            |
  |                                                                            |
  | [T] grand total squared / #scores : 4231249                                |
  |                                                                            |
  | [A] column total squares / #rows : 4465010.17                              |
  |                                                                            |
  | [AS] sum of all squared scores : 4659200.00                                |
  |                                                                            |
  | SS(T) total sum of squares : 427951.00                                     |
  |                                                                            |
  | SS(A) between group sum of squares : 233761.17                             |
  |                                                                            |
  | SS(S/A) total within group sum of squares : 194189.83                      |
  |                                                                            |
  | Mean square(A), SS(A) / df(A) : 116880.585                                 |
  |                                                                            |
  | Mean square(S/A), SS(S/A) / df(S/A) : 5884.5403                            |
  |                                                                            |
  | F ratio : 19.8623136                                                       |
  |                                                                            |
  | If F is close to 1.0, then there is little variance between column results |  
  +----------------------------------------------------------------------------+

 Example of use
  ex anova2 anova.in >outfile

 Explanation
  In the example above, input values within file "infile" are analyzed.
  Results are stored into "outfile".

 Equations are from: "Design & Analysis", Geoffrey Keppel, ISBN 0-13-200048-2
*/

parse arg statfile .

if statfile = '' then
  signal usagemsg

 /* initialize multiple values to 0 */

parse value 0 with ,
  1 row 1 numberColumns 1 AS. 1 T. 1 grandTotal 1 sumOfColumnTotalSquares ,
  1 totalSumOfSquares 1 betweenGroupSumOfSquares 1 withinGroupSumOfSquares. ,
  1 sumOfSquaredScores 1 totalWithinGroupSumOfSquares

coltitles = linein( statfile )         /* get column titles */

call split coltitles, 'COLTITLE.'

do lines( statfile )
  lin = linein( statfile )
  if lin = '' then iterate
  row = row + 1
  numberColumns = max( numberColumns, words( lin ) )
  do col=1 while lin <> ''
    parse var lin v lin
	T.col = T.col + v /* column total */
	AS.row.col = v
	call charout , right( v, 12 )
    end
  say
  end

say

numberRows = row

numberOfScores = ( numberRows * numberColumns )

do i=1 to numberColumns
  sumOfColumnTotalSquares = sumOfColumnTotalSquares + ( T.i * T.i )
  say 'Column' coltitle.i ': total' T.i', mean:' ( T.i / numberRows )
  grandTotal = grandTotal + T.i
  end

grandMean = grandTotal / numberOfScores

say
say 'Grand total' grandTotal', grand mean:' grandMean
say

do i=1 to numberColumns
  colDeviation = ( ( T.i / numberRows ) - grandMean )
  say 'Subject deviation column' coltitle.i ':' colDeviation
  betweenGroupSumOfSquares = betweenGroupSumOfSquares + ( numberRows * ( colDeviation * colDeviation ) ) 
  end

say
say 'Between group sum of squares :' betweenGroupSumOfSquares

do j=1 to numberColumns
  do i=1 to numberRows
	sumOfSquaredScores = sumOfSquaredScores + ( AS.i.j * AS.i.j )
	colDeviation = ( AS.i.j - ( T.j / numberRows ) )
	withinGroupSumOfSquares.j = withinGroupSumOfSquares.j + ( colDeviation * colDeviation )
	deviation = grandMean - AS.i.j
	totalSumOfSquares = totalSumOfSquares + ( deviation * deviation ) 
	end
  end

say
say 'Total sum of squares :' totalSumOfSquares

do i=1 to numberColumns
  say
  say 'Column' coltitle.i
  say '  Within group sum of squares :' withinGroupSumOfSquares.i
  totalWithinGroupSumOfSquares = totalWithinGroupSumOfSquares + withinGroupSumOfSquares.i 
  if numberRows > 1 then do
    say '  Variance :' ( withinGroupSumOfSquares.i / ( numberRows - 1 ) )
    say '  Std. dev. :' sqrt( withinGroupSumOfSquares.i / ( numberRows - 1 ) )
    end
  end

say
say 'Total within group sum of squares :' totalWithinGroupSumOfSquares

say
say 'Sum of squared scores :' sumOfSquaredScores

say
say 'Sum of column total squares :' sumOfColumnTotalSquares

say
say 'Grand total squared :' grandTotal * grandTotal

say
say '[T] grand total squared / #scores :' ( grandTotal * grandTotal ) / numberOfScores

say
say '[A] column total squares / #rows :' sumOfColumnTotalSquares / numberRows

say
say '[AS] sum of all squared scores :' sumOfSquaredScores

say
say 'SS(T) total sum of squares :' sumOfSquaredScores - ( ( grandTotal * grandTotal ) / numberOfScores ) 

say
say 'SS(A) between group sum of squares :' ( sumOfColumnTotalSquares / numberRows ) - ( ( grandTotal * grandTotal ) / numberOfScores ) 

say
say 'SS(S/A) total within group sum of squares :' sumOfSquaredScores - ( sumOfColumnTotalSquares / numberRows )

/* end of chapter 2 computations */

/* chapter 3 */

if numberRows > 1 & numberColumns > 1 then do

  MSa = ( ( sumOfColumnTotalSquares / numberRows ) - ( ( grandTotal * grandTotal ) / numberOfScores ) ) / ( numberColumns - 1 )

  MSsa = ( sumOfSquaredScores - ( sumOfColumnTotalSquares / numberRows ) ) / ( numberColumns * ( numberRows - 1 ) )

  say
  say 'Mean square(A), SS(A) / df(A) :' MSa

  say
  say 'Mean square(S/A), SS(S/A) / df(S/A) :' MSsa

  say
  say 'F ratio :' ( MSa / MSsa )

  say
  say 'If F is close to 1.0, then there is little variance between column results'
  end

exit 0

	/* procedure SQRT
	 * computes square root of argument
	 */

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

	/* procedure SPLIT
	 * splits a space-separated value line into its constituent fields
	 * the 'stem' parameter identifies a collection of compound variables to assign
	 *
	 * on return,
	 *  STEM.length -- is the number of compound variables assigned
	 *  STEM.1 -- is the first field value
	 *  STEM.2 -- is the second field value
	 *   .
	 *   . [etc]
	 *   .
	 *
	 * result:
	 *  STEM.length is returned
	 */

split :

  parse arg lin , stem

  nFields = 0

  do while lin <> ''
    nFields = nFields + 1
    parse var lin word lin
    call value stem || nFields, word /* assign field */
    end

  call value stem'LENGTH', nFields /* STEM.LENGTH => #fields */

  return nFields

	/* procedure USAGEMSG
	 * shows usage message
	 */

usagemsg :
  call lineout '!', 'usage'
  call lineout '!', '  ex anova2 statfile [ > outfile ]'
  exit 1
