/* TopoSort.rex
 topological sort

 identifies the order of dependences from most dependent to least dependent

 usage
  r4 TopoSort [MixedCase] <infile >outfile

 example input file -- a series of dependency definitions:

    +-------+
    |  a b  |
    |  b c  |
    |  b e  |
    |  c d  |
    |  b f  |
    |  m n  |
    |  n o  |
    |  o p  |
    |  m r  |
    |  m s  |
    +-------+

 corresponding output file a tree showing levels of dependency:

    +-------------+
    |A            |
    |+ B [A]      |
    |++ C [B]     |
    |+++ D [C]    |
    |++ E [B]     |
    |++ F [B]     |
    |M            |
    |+ N [M]      |
    |++ O [N]     |
    |+++ P [O]    |
    |+ R [M]      |
    |+ S [M]      |
    +-------------+
*/

if translate( left( arg(1), 1 ) ) = 'M' then
  characterCase = 'M'

else if arg(1) <> '' then do
  call lineout !, 'Usage'
  call lineout !, ' r4 TopoSort [MixedCase] <infile >outfile'
  exit 1
  end

else
  characterCase = 'U' /* default is Parentcase */


 /* initialize variables
  * nItems = 0
  * nLevels = 0
  * items = ''
  * itemDepth. = 0
  * dependsOn. = ''
  * dependeeOf. = ''
  * shownItems = ''
  * prevFrom = ''
  */

parse value 0 0 0 with ,
  nItems nLevels itemDepth. ,
  items dependsOn. dependeeOf. shownItems prevFrom

do lines()

  if characterCase = 'U' then
    parse UPPER linein From To .
  else
    parse linein From To .

  if From = To | DetectCycle( To ) then do
    call lineout !, 'Cycle detected.' From '<->' To'...'
	exit 1
	end

  dependsOn.From = dependsOn.From To

  dependeeOf.To = dependeeOf.To From

  call ReviseDepth From To

  call AddItem From

  call AddItem To

  if From <> prevFrom then do
    /* call lineout !, From */
    prevFrom = From
    end
  
  end /* end lines() loop */

do i=nLevels to 0 by -1
  
  replicas = items
  
  do while replicas <> ''
    parse var replicas From replicas
    if itemDepth.From = i then
      call ShowItem From '_'
    end
  
  end

exit 0

ReviseDepth : procedure expose nLevels itemDepth. dependeeOf.
  
  parse arg From To
  
  itemDepth.From = max( itemDepth.From, itemDepth.To + 1 )
  
  nLevels = max( nLevels, itemDepth.From )

  /* debugging...
  if length( dependeeOf.From ) > 1 then
    say copies( '.', 1 + itemDepth.From ) From '->' dependeeOf.From
  */
  
  dependees = dependeeOf.From
  
  do while dependees <> ''
    parse var dependees dependee dependees
    call ReviseDepth dependee From
    end
  
  return

AddItem : procedure expose nItems items
  
  parse arg Item
  
  if wordpos( Item, items ) = 0 then do
    items = items Item
    nItems = nItems + 1
    end
  
  return

ShowItem : procedure expose nLevels shownItems itemDepth. dependsOn.
  
  parse arg Item Parent

  itemSeenBefore = ( wordpos( Item, shownItems ) > 0 )

  if itemSeenBefore & parent = '_' then
    return

  if Parent = '_' then
    say Item
  else
    say copies( '+', 1 + (nLevels - itemDepth.Parent) ) Item '['Parent']'
  
  if \ itemSeenBefore then
    shownItems = shownItems || copies( ' ', shownItems <> '' ) || Item	

  dependees = dependsOn.Item

  do while dependees <> ''
    parse var dependees To dependees
    call ShowItem To Item
    end

  return

DetectCycle : procedure expose From dependsOn.
  
  parse arg To
  
  if wordpos( From, dependsOn.To ) > 0 then
    return 1
  
  return 0
