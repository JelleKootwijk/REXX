/* lottery.rex, this procedure helps you pick 6 lottery numbers

 Keywords
  Random number generation, Compound symbol arrays

 Usage
  r4 lottery [high-limit]

 Arguments
  Optional upper limit for numeric picks [must exceed 19, default: 49]

 Files used
  Standard input
  Standard output

 Exit codes
   0   => always succeeds
 non-0 => [never fails]

 Input record format
  N/A

 Sample input file
  N/A

 Sample output file
  The following was produced by: r4 lottery 39
  ีออออออออออออออออออออออออออออออออออออออออธ
  ณ    Here come 6 picks [range: 1-39]     ณ
  ณ            31 15 19 4 6 3              ณ
  ณ               Good luck                ณ
  ิออออออออออออออออออออออออออออออออออออออออพ

 Example of use
  [1] r4 lottery
  [2] r4 lottery 39

 Explanation
  This procedure displays 6 random numbers in the range of 1 to the upper
  limit. Alternative upper limits which exceed 19 can be set. The default
  upper limit is 49. 

  In the examples above,
   [1] 6 numbers in the range 1 to 49 are displayed.
   [2] 6 numbers in the range 1 to 39 are displayed.

 !!! numbers displayed are N-O-T guaranteed to be winners
*/

arg limit .

if limit = '' then
  limit = 49 /* default */

else if datatype( limit, whole ) <> 1 then do
  say "Lottery argument("limit") should be numeric; using '49' as limit"
  limit = 49 /* default */
  end

else if limit <= 19 then do
  say "Lottery argument("limit") should exceed 19; using '49' as limit"
  limit = 49 /* default */
  end

picks = ''                                               /* selected picks */

	/* prepare 6 random numbers */

do until words( picks ) = 6                                /* need 6 picks */
  	 
  pick = random( 1, limit )                   /* get another random number */

  if wordpos( pick, picks ) = 0 then                /* not already picked? */
    picks = picks pick                                    /* remember pick */

  end /* end loop */

	/* format results */

say center( "Here come 6 picks [range: 1-"limit"]", 79 )     /* title line */

say center( strip( picks ), 79 )                           /* show 6 picks */

say center( "Good luck", 79 )                            /* closing remark */

exit 0

