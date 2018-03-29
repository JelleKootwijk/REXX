/* bj.rex */

parse source sys . .

cash = 1000

stake = 1

signal deal

rep :
  stake = 1
  
  cash = cash + bump

  say
  if cash < 1 then do
    say 'Cash:' cash '.. Game Over.   ;-<'
    exit
    end
    
trace off    

  call charout , 'Cash:' cash 'Again ? (Enter/Q) '

  if 'Q' = translate( strip( linein() ) ) then
    exit

deal :
    
trace off    

  bump = 0

  if words( shoe ) < 26 then
    call shuffle

trace 'O'

  yours = take( 2 )
  jacks = take( 2 )

  call show yours, word( jacks, 1 )

  if total( yours ) = 21 then do
    say 'Blackjack  \8-))'

    if total( jacks ) < 21 then
      bump = 15
    else do
      call show yours, jacks
      say 'Jack has 21!  Push.  ]:-#'
      end
    signal rep
    end

  if total( jacks ) = 21 then do
    call show yours, jacks
    say 'Jack has 21!    #:-o'
    bump = - 10 * stake
    signal rep
    end

you :

  yourTotal = total( yours )

  if yourTotal < 21 then
    if hit( yourTotal >= 9 & yourTotal <= 12 ) then do
      yours = yours take( 1 )
      call show yours, word( jacks, 1 )
      if total( yours ) > 21 then do
        say 'BUST !!    ]:-o"'
        bump = - 10 * stake
        signal rep
        end
      signal you
      end

jack :

trace '0'

  call show yours, jacks

/*
say 'stake' stake
*/

  if total( jacks ) > 21 then do
    say "Jack's BUST !!    \:,"
    bump = 10 * stake
    signal rep
    end

  if jackHit() then do
    jacks = jacks take( 1 )
    signal jack
    end

  parse value total( yours ) total( jacks ) with you jack

  if you > jack then do
    say 'You win !!    8-)'
    bump = 10 * stake
    end

  else if you < jack then do
    say 'You lose !!    /:-('
    bump = - 10 * stake
    end

  else
    say 'Push.  ]:-#'

  signal rep

sum :
  cards = arg( 1 )
  parse value 0 0 with total nAces text
  do while cards \= ''
    parse var cards card cards
    which = card // 13
    nAces = nAces + ( which = 0 )
    total = total + word( min( which + 1, 10 ) 11, 1 + ( which = 0 ) )
    end
  return total

decorate : procedure
  call charout , arg( 1 )
  cards = arg( 2 )
  s = ''
  do while cards \= ''
    parse var cards card cards
    if sys \= 'PalmOS' then 
      s = s d2c( word( 6 3 4 5, 1 + card // 4 ) )
    s = s || word( 'A 2 3 4 5 6 7 8 9 10 J Q K', 1 + ( card // 13 ) )
    end
  say s
  say
  return

hit : procedure expose stake
  canDouble = arg(1)
  do forever
    call charout , 'Hit ? (Hit | No'copies( ' | Double', canDouble )') '
    ch = translate( strip( linein() ) )
    if canDouble & ( ch = 'D' ) then
      stake = 2
    if pos( ch, 'DHN' ) > 0 then
      return ch <> 'N'
    end

jackHit :
  return reduce( sum( jacks ), nAces, 0 ) < 17

reduce : procedure
  parse arg total, nAces, first
  do nAces
    if first & total < 22 then
      return total
    if \ first & total > 16 & total < 22 then
      return total
    total = total - 10
    end
  return total

show :
  if sys = 'PalmOS' then 
    say d2c(27)"[2j"
  else
    'cls'

  say ' Cash:' cash '___Beat Jack  8^;'
  say 
  call decorate 'Yours: ', arg( 1 )
  call decorate "Jack's:", arg( 2 )
  return

take :
  cd = subword( shoe, 1, arg( 1 ) )
  shoe = subword( shoe, 1 + arg( 1 ) )
  return cd

total : procedure
  return reduce( sum( arg( 1 ) ), nAces, 1 )

shuffle : procedure expose shoe
  say 'Shuffling "shoe".'
  shoe = ''
  do 4
    cards = ''
    do 52
      do forever
        call charout , '.'
        card = random( 1, 52 )
        if wordpos( card, cards ) = 0 then do
          cards = cards card
          leave
          end
        end
      end
    shoe = shoe cards
    end
  return
