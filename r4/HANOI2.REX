/* hanoi2.rex
 a REXX implmentation of the hanoi tower game, whereby rings are rearranged between 3 pegs,
 with the rule that a larger ring cannot be placed on top of a smaller ring

                STARTING POSITION
               -------------------

        |              |              |
      [ . ]            |              |
     [ . . ]           |              |
    [ . . . ]          |              |
  =============  =============  =============
      left           middle         right


                  GOAL POSITION
                 ---------------

        |              |              |
        |              |            [ . ]     
        |              |           [ . . ]    
        |              |          [ . . . ]   
  =============  =============  =============
      left           middle         right

 usage
   ex hanoi2 #rings [on first peg]

 note:
  this program performs simple animation by using the NAP.EXE program
  to wait for 50 milliseconds between cycles
*/

arg n_rings .

if n_rings = '' then
  call usagemsg

if \datatype( n_rings, 'W' ) then
  call usagemsg "Invalid argument (whole number expected):" n_rings

if \range( n_rings, 3, 9 ) then
  call usagemsg "Invalid argument (range 3 to 9):" n_rings

	/* initialize starting position */

do i=1 to n_rings
  peg_of_ring.i = left		/* "peg_of_ring." => which peg each ring is on */
  left.i = (n_rings - i) + 1  /* add rings to left peg biggest to littlest */
  end

middle. = 0                                       /* "middle" peg is empty */
right.  = 0                                       /* "right"  peg is empty */

peg.left   = n_rings                 /* #rings on left   peg [all of them] */

peg.middle = 0                              /* #rings on middle peg [none] */
peg.right  = 0                              /* #rings on right  peg [none] */

call show_picture

call move n_rings left middle right

say
say "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
say

say " " "Goal position REACHED !!!"

exit

	/* MOVE procedure
	 * moves rings between pegs
	 */

move : procedure expose peg_of_ring. peg. left. middle. right.
  arg mv_ring peg_left peg_middle peg_right

  if mv_ring <= 0 then
    return

  if mv_ring = 1 then
    call ring_to_peg  mv_ring  peg_of_ring.1 /* --> */ peg_right

  else do

    call move           (mv_ring-1)  peg_left peg_right peg_middle

    call ring_to_peg    mv_ring      peg_of_ring.mv_ring /* --> */ peg_right

    call move           (mv_ring-1)  peg_middle peg_left peg_right

    end
     
  return

	/* RING_TO_PEG procedure
	 * moves a ring from one peg to another
	 */

ring_to_peg : procedure expose peg_of_ring. peg. left. middle. right.
  arg ring_no from_peg to_peg

  peg.from_peg = peg.from_peg - 1              /* decrease "from" peg height */
  peg.to_peg   = peg.to_peg + 1                /* increase "to"   peg height */

  call value to_peg"." || peg.to_peg , ring_no        /* advanced assignment */

  peg_of_ring.ring_no = to_peg

  call show_picture

  return

	/* SHOW_PICTURE procedure
	 * shows rings on each peg
	 */

show_picture : procedure expose peg. left. middle. right.

  cls	/* clear screen */

	/* show left peg */

  say; say; say
  call show "|"

  do i=peg.left to 1 by -1
    call show "[" copies( '. ', left.i )"]"
    end
  call show copies( "=", 26 )
  call show "left"

	/* show middle peg */

  say; say; say
  call show "|"
  do i=peg.middle to 1 by -1
    /* if i <> peg.middle then options drek */
    call show "[" copies( '. ', middle.i )"]"
   end
  call show copies( "=", 26 )
  call show "middle"

	/* show right peg */

  say; say; say
  call show "|"
  do i=peg.right to 1 by -1
    call show "[" copies( '. ', right.i )"]"
   end
  call show copies( "=", 26 )
  call show "right"

	/* take a nap */

  nap 50	/* uses NAP.EXE */

  return

	/* SHOW procedure
	 * centers text within a 26 character cell
	 */

show : procedure
  say center( arg(1), 26 )
  return

	/* RANGE procedure
	 * validates range of argument
	 */

range : procedure
  parse arg n, lo, hi
  return n >= lo & n <= hi

	/* USAGEMSG procedure
	 * shows program usage information
	 */

usagemsg : procedure
  if arg( 1, 'E' ) then
    call lineout !, arg( 1 )
  call lineout !, 'Usage:'
  call lineout !, ' r4 hanoi2 nRings'
  exit 1