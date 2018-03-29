/* hanoi1.rex
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

 this version tells "YOU" how to move the rings from peg to peg

 usage
   ex hanoi1 #rings [on first peg]

 note:
  the HANOI2.REX version is more exciting
*/

arg n_rings .							/* get #rings on left peg */

call move n_rings left middle right		/* recursively move rings */

exit

	/* MOVE procedure, recursive
	 * tells how to move Nth ring
	 */

move : procedure
  arg mv_ring peg_left peg_middle peg_right

  if mv_ring = 0 then
    return

  if mv_ring = 1 then
    say 'move ring' mv_ring 'to' peg_right				/* tell */

  else do
    call move (mv_ring-1) peg_left peg_right peg_middle	/* recurse */

    say 'move ring' mv_ring 'to' peg_right				/* tell */

    call move (mv_ring-1) peg_middle peg_left peg_right	/* recurse */
    end
     
  return
