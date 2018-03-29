/* easter.rex
 computes easter for this year, or a specific year

 from Scientific American, Mar 2001 p82

 usage:
  r4 easter [year]


 the EASTER program can be used with the SEQ.REX program
 and the ! command shell to discovers a sequence of
 Easters as follows:

   ! r4 easter `r4 seq 2000 2050`
*/

	/* get year argument */

parse arg year .

if year = '' then
  year = left( date( 'S' ), 4 )		/* get this year */

a = year // 19

b = year % 100

c = year // 100

d = b % 4

e = b // 4

g = ( ( 8 * b ) + 13 ) % 25

h = ( ( 19 * a ) + b - d - g + 15 ) // 30

m = ( a + 11 * h ) % 319

j = c % 4

k = c // 4

l = ( ( 2 * e ) + ( 2 * j ) - k - h + m + 32 ) // 7

n = ( h - m + l + 90 ) % 25

p = ( h - m + l + n + 19 ) // 32

if n = 3 then
  say 'March' right( p, 2 )',' year

else
  say 'April' right( p, 2 )',' year
