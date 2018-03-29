/* permute.rex, mathematical permutations of n items taken m at a time
   ie. P(n,m) or nPm

 Keywords
  Mathematical 'permutations' computation

 Usage
  r4 permute n_items m_per_group

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
  The following was produced by: r4 permute 52 5

   P(52,5) is:  311875201


 Example of use
  r4 permute 4 2

 Explanation
  This procedure determines the mathematical number of possible unique
  groupings of 'n' items taken 'm' at a time. This is usually expressed
  in the following forms:
   P(n,m)     ie. P(4,2) --> 12
   nPm        ie. 4P2    --> 12

  In the example above,
   The number of order dependent permutations of 4 things into groups of 2
   is determined:
    P(4,2) is: 12
*/
arg n m

if datatype( n ) <> NUM | datatype( m ) <> NUM then do
  call lineout !, 'Usage:'
  call lineout !, '  r4 permute #items groupsize'
  call lineout !, '  r4 permute 4 2'
  exit 1
  end

say 'P('n','m') is: ' factorial( n ) / factorial( n - m )

exit


factorial: procedure
  arg n

  factorial = 1

  do i=1 to n
    factorial = i * factorial
    end

  return factorial
