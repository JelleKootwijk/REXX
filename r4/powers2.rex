/* powers2.rex, display powers of 2

 Keywords
  Mathematical "powers of 2" presentation, Numeric argument clipping

 Usage
  r4 powers2 [limit [step]]   [default limit: 64] [default step: 4]

 Arguments
  1. optional limit value, range 16 to 64, default limit is 64
  2. optional step  value, range  1 to  4, default step  is  4
  If either the limit or step is outside of bounds, the default value
  is used instead.

 Files used
  Standard output

 Exit codes
   0   => always succeeds
 non-0 => never fails

 Input record format
  N/A

 Sample input file
  N/A

 Sample output file
  The following was produced by: r4 powers2 32
  ีออออออออออออออธ
  ณ N    2^N     ณ
  ณ-- ---------- ณ
  ณ 0          1 ณ
  ณ 4         16 ณ
  ณ 8        256 ณ
  ณ12       4096 ณ
  ณ16      65536 ณ
  ณ20    1048576 ณ
  ณ24   16777216 ณ
  ณ28  268435456 ณ
  ณ32 4294967296 ณ
  ิออออออออออออออพ

 Example of use
  [1] r4 powers2
  [2] r4 powers2 56
  [3] r4 powers2 16 1

 Explanation
  This procedure shows a table of the powers of 2 from 2**0 to 2**limit
  in step increments. The limit and step size are optional arguments.

  In the examples above,
   The following tables are displayed
   [1] 2**N: from 2**0 to 2**64 in steps of 4
   [2] 2**N: from 2**0 to 2**56 in steps of 4
   [3] 2**N: from 2**0 to 2**16 in steps of 1
*/

	/* establish loop controls from arguments */

arg inlimit instep .

	/* establish  controls  lowest   highest  default  */

limit = clip(     inlimit,    16,      64,       64  )
step  = clip(     instep,      1,       4,        4  )

tab = d2c( 9 )                       /* set this to "" to deactivate tabbing */

numeric digits 20                             /* anticipate large numbers */

width = length( 2 ** limit )            /* compute variable display width */

	/* show title lines */

say tab " N" center( "2^N", width )                    /* a helpful title */

say tab "--" copies( "-", width )                       /* a divider line */

	/* show table */

do i = 0 to limit by step             /* 2**0 to 2**Limit in "step" units */

  say tab right( i, 2 ) right( 2 ** i, width )     /* show 'i' and '2**i' */

  end

exit 0

 /* CLIP procedure
  * clips number within range minn to maxn, or default
  */
clip : procedure
  arg n, minn, maxn, defaultn
  if n = "" then
    answer = defaultn                        /* number undefined => default */
  else if datatype( n ) <> num then
    answer = defaultn                             /* non-numeric => default */
  else
    answer = min( max( minn, n ), maxn )        /* clip:  minn <= n <= maxn */
  return answer
