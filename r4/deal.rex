/* deal.rex -- deals 52 cards to 4 hands
 usage
  r4 deal
*/

if arg(1) <> '' then
  signal usagemsg

hand. = '' /* this compound variable holds dealt hands */

call dealCards

call displayUsingBridgeFormat

exit 0

/* the 'convertCard' procedure converts 10, 11, 12, 13 to Jack, Queen, King, Ace */

convertCard : procedure
  return word( 'A 2 3 4 5 6 7 8 9 10 J Q K', 1 + ( arg(1) // 13 ) )

/* the 'dealCards' procedure assigns cards to hands */

dealCards : procedure expose hand.

  cards = shuffleCards()

  /* assign cards to hands */

  do i=1 for 4
    call getHand i, subword( cards, 13 * ( i - 1 ) + 1, 13 )
    end
  
  return

/* the 'displayUsingBridgeFormat' procedure shows hands in Bridge format */

displayUsingBridgeFormat : procedure expose hand.

  /* format hands as normally displayed in Bridge texts */

  say

  say copies( ' ', 30 ) 'North'

  do i=1 for 4
    say copies( ' ', 30 ) hand.1.i
    end

  say 'West' copies( ' ', 50 ) 'East'

  do i=1 for 4
    say left( hand.2.i, 55 ) hand.3.i
    end

  say copies( ' ', 30 ) 'South'

  do i=1 for 4
    say copies( ' ', 30 ) hand.4.i
    end

  return

/* the 'getHand' procedure prepares a hand of cards */

getHand : procedure expose hand.
  arg n, cards

  /* sort cards in this hand from highest to lowest .. queue results */

  cards = sortDescending( cards )

  /* assign cards to suits */

  suit. = ''

  do i=1 for 13
    card = word( cards, i )
	whichSuit = 1 + ( ( card - 1 ) % 13 )
    suit.whichSuit = suit.whichSuit convertCard( card )
    end

  /* a Windows command window shows binary 3..6 as card suit images */

  suitImage = d2c( 6 ) d2c( 3 ) d2c( 4 ) d2c( 5 ) /* spade heard diamond club */

  do whichSuit=1 for 4
    hand.n.whichSuit = word( suitImage, whichSuit ) suit.whichSuit
    end

  return /* showhand */

/* the 'getWords' procedure assigns words to stem WORD. */

getWords : procedure expose word.
  s = arg(1)
  word.0 = words( s )
  do i=1 for words( s )
    word.i = word( s, i )
    end
  return word.0

/* the 'shuffleCards' procedure deals 52 cards in a random sequence */

shuffleCards : procedure
  cards = ''

  do 52
    do forever
      newCard = random( 1, 52 )
      if wordpos( newCard, cards ) = 0 then do
        cards = cards newCard
        leave
        end
      end
    end

  return cards

/* the 'sortDescending' procedure sorts words in descending numeric order */

sortDescending : procedure
  word. = ''
  
  call getWords arg( 1 )

  /* shell sort */

  do n = 1 for 3                /* 3 passes */

    incr = 2**n - 1

    do j = incr + 1 for word.0
      i = j - incr
      xchg = word.j
      
      do while xchg > word.i & i > 0
        m = i + incr
        word.m = word.i
        i = i - incr
        end /* do while xchg ... */

      m = i + incr
      word.m = xchg
      
      end j /* do j = incr ... */
    
    end n /* do n = 1 ... */

  return stringWords()

/* the 'stringWords' procedure ravels the words in WORD. */

stringWords : procedure expose word.

  string = ''

  do i=1 for word.0
    string = string word.i
    end

  return strip( string, 'L' )

/* usage information */

usagemsg :
  call lineout !, '0a'x || 'No arguments are expected'
  call lineout !, ''
  call lineout !, 'Usage'
  call lineout !, '  r4 deal'