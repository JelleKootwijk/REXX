/* combine.rex, mathematical combinations of 'n' items taken 'm' at a time
   ie. C(n,m) or nCm

 Keywords
  Mathematical 'combinations' computation

 Usage
  r4 combine n_items m_per_group

 Arguments
  1. number of total items
  2. items per group

 Files used
  Standard output

 Exit codes
   0   => processing completed normally
 non-0 => usage error

 Input record format
  N/A

 Sample input file
  N/A

 Sample output file
  The following output is displayed
  for the example request below.

    C(52,5) is:  2598960.01

 Example of use
  r4 combine 52 5

 Explanation
  This procedure determines the mathematical number of possible combinations
  of 'n' items grouped 'm' at a time, independent of group ordering. This is
  usually expressed in the following forms:
   C(n,m)     ie. C(4,2) --> 6
   nCm        ie. 4C2    --> 6

  In the example above,
   The number of possible 5-card stud poker hands is determined:
    C(52,5) is: 2598960
*/

arg n m                                                  /* get 2 arguments */

if datatype( n ) <> NUM | datatype( m ) <> NUM then do
  call lineout !, 'Usage:'
  call lineout !, '  r4 combine #items groupsize'
  call lineout !, '  r4 combine 4 2'
  exit 1
  end

say 'C('n','m') is: ' factorial( n ) / (factorial( m ) * factorial( n - m))

exit 0

factorial: procedure
  arg n

  factorial = 1

  do i=1 to n
    factorial = i * factorial
    end

  return factorial
