/* changestr.rex -- DEPRECATED !!

 an EXTERNAL PROCEDURE that emulates the 'changestr' builtin function
 that is available in NetRexx and roo!(TM)

 usage:
  result = changestr( str, before, after )

 Important N-O-T-E:

  This implementation provides compatibility with the NetRexx/roo!(TM)
  specification of the 'changestr' function. r4(TM) provides the
  'changestr' built-in function, which is compatible with the ANSI
  specification of the 'changestr' function. The built-in function
  performs considerably quicker than this external procedure.
*/

if arg() <> 3 then
  return 40 /* incorrect call to routine */

parse arg str, before, after

/* note: the length of 'str' can be 0 */

if length( before ) = 0 then
  return 40 /* incorrect call to routine */

/* note: the length of 'after' can be 0 */

res = ''

do while str <> ''

  if pos( before, str ) = 0 then
    leave

  parse var str left (before) str

  res = res || left || after 

  end

return res || str