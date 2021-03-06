/* matrix.rex, format standard input into multiple columns, column order

 Keywords
  Multiple column output, Column order output, Matrix file display

 Usage
  r4 matrix #rows #columns [col_colWidth]

 Arguments
  1. number of rows until pause or complete
  2. number of columns per row

 Files used
  Standard input
  Standard output

 Exit codes
   0   => successful completion
 non-0 => invalid usage

 Input record format
  Lines within input files are Ascii text. These lines usually contain a
  single word or phrase which would look appropriate in a multiple column
  matrix.

 Sample input file
  嬪様様様様様様邑
  �files('*.rex')�
  �ADDNAD.REX    �
  �APPLY.REX     �
  �AREACODE.REX  �
  �BARGRAPH.REX  �
  �BIGGEST.REX   �
  �CAL.REX       �
  �CALC.REX      �
  �CALDISP.REX   �
  �CAT.REX       �
  �CHARCOPY.REX  �
  �CHGALL.REX    �
  �COLLIM8.REX   �
  �COMBINE.REX   �
  �COOKIE.REX    �
  � .            �
  � .            �
  � .            �
  塒様様様様様様余

 Sample output file
  嬪様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様邑
  �files('*.rex') COOKIE.REX     FINDDATE.REX   MAVERAGE.REX   QUIZAVG.REX �
  �ADDNAD.REX     COUNTDWN.REX   FLDSEP.REX     MTOFEET.REX    REXXTRY.REX �
  �APPLY.REX      CPANEL.REX     FUTVAL.REX     ORDER.REX      ROBOT.REX   �
  �AREACODE.REX   CUT.REX        HCHART.REX     ORDERENT.REX   SPLICE.REX  �
  �BARGRAPH.REX   DOCPROG.REX    HEAD.REX       PAD.REX        SUFFIX.REX  �
  �BIGGEST.REX    DROP.REX       HELLO.REX      PAGE.REX       SUMEXT.REX  �
  �CAL.REX        EDALL.REX      HELP.REX       PASTE.REX      TIMEVAL.REX �
  �CALC.REX       FACTOR1.REX    HEXCALC.REX    PAYMENT.REX    TODO.REX    �
  �CALDISP.REX    FACTOR2.REX    HEXIT.REX      PERMUTE.REX    TOPIC.REX   �
  �CAT.REX        FACTOR3.REX    HX.REX         PICK.REX       UCALC.REX   �
  �CHARCOPY.REX   FC.REX         LATEST.REX     POWERS2.REX    UPCASE.REX  �
  �CHGALL.REX     FILECOPY.REX   LOTTERY.REX    PREFIX.REX     VCHART.REX  �
  �COLLIM8.REX    FIND.REX       LOWCASE.REX    QUERY.REX      WISHFUL.REX �
  �COMBINE.REX    FINDALL.REX    MATRIX.REX     QUIZ.REX       XMPIX.REX   �
  塒様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様様余

 Example of use
  dir /b ex | sort | drop 5 | cut 1 | r4 matrix 14 5
*/

arg nRows nColumns colWidth .

call validate

parse value 0 1 with ,
  nPendingRows , /* = 0                          begin with no pending rows */
  nColumn  ,     /* = 1                               begin with 1st column */
  row.           /* = ""                               all rows start empty */

do nRow = 1 while lines() > 0

   /* add another column to current row */

  row.nRow = row.nRow || left( linein(), colWidth )/* append another column */

  if ( nRow // nRows ) = 0 then do                     /* row limit reached */

      nPendingRows = nRows                                 /* limit reached */

      if ( nColumn // nColumns ) = 0 then do   /* column limit also reached */
           
           /* show retained rows */
          do i=1 to nRows                                  /* show "m" rows */
            say strip( row.i )                              /* show row "i" */
            end

           /* stop to permit user to analyze current output */
          
          call lineout !, 'Press any character to continue...'
          
          x = charin( ! )

          parse value 0 1 with nPendingRows currCol row.  /* reset controls */

          end

      nRow = 0                                         /* back to beginning */
      nColumn = nColumn + 1                             /* increment column */
      end

  nPendingRows = max( nPendingRows, nRow )        /* remember #pending rows */
  end

 /* show pending rows */

do i=1 to nPendingRows                             /* show all pending rows */
  say strip( row.i )                                        /* show row "i" */
  end

exit 0

 /* procedure VALIDATE
  * validate arguments
  */

validate : /* expose all */

  if datatype( nRows, wholenumber ) <> 1 then
    call usagemsg 'The #rows must be a whole number'

  if datatype( nColumns, wholenumber ) <> 1 then
    call usagemsg 'The #columns must be a whole number'

  if nRows < 1 | nRows > 100 then
    call usagemsg 'The #rows must be between 1 and 100'

  if ncol < 1 then
    call usagemsg

  if colWidth <> '' then do
    if datatype( colWidth, wholenumber ) <> 1 then
      call usagemsg 'The column width must be a whole number'
    end

  else
    colWidth = trunc( (80-nColumns) / nColumns )   /* compute default colWidth */

/* optional validation

  if ( nColumns * colWidth ) > 80 then
    call usagemsg 'The product of the #columns and the column width cannot exceed 80'

*/

  return


usagemsg :
  if arg( 1 ) <> '' then do
    call lineout !, 'Note:' arg( 1 )
    call lineout !, ''
	end
  call lineout '!', 'Usage'
  call lineout '!', ' r4 matrix #rows #columns [colcolWidth]'
  call lineout '!', ' ie. ex matrix 10 5 12 <infile'
  exit 1
