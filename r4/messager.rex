/* messager.rex
 demonstration program that uses MSGBOX.EXE

 usage:
  r4 messager

 refer to MSGBOX.HTM for a description of the usage of MSGBOX.EXE
*/

/* prepare the message box style,
   
   it is the numeric sum of up to four of the following numeric style values:


     1. type of button(s) to use

      0 - OK
      1 - OK(1) Cancel(2)
      2 - Abort(3) Retry(4) Ignore(5)
      3 - Yes(6) No(7) Cancel(2)
      4 - Yes(6) No(7)
      5 - Retry(4) Cancel(2)


     2. optional, type of icon to display within the message

      16 - stop image
      32 - question mark
      48 - exclamation mark
      64 - information bubble


     3. optional, default button selector

      256 - the second button receives the initial focus
      512 - the third button receives the initial focus
      1024 - the fourth button receives the initial focus


     4. optional, final style

      262144 - indicates message window will float above all other windows



     Thus, a style value of 292 (4 + 32 + 256) is interpreted as:

      show 'Yes' and 'No' buttons                     4

      the 'question mark' icon is displayed       +  32

      the 'No' button initially has the focus     + 256

                                                  =====

                                             total: 292
*/

style = 4 + 32 + 256

crlf = '0D0A'x

caption = 'Magic words:'

messageText = 'Here are some magic words'crlf||crlf'shazam'crlf'open sesame'crlf'abracadabra'

trace C

/* invoke MSGBOX.EXE

  note:
    the caption option is bracketed with double quotes
	because the caption contains a space
*/

MsgBox '"-C'caption'"' '-S'style messageText

/* the RC indicates which button was pressed */

button. = '_unknown_'
button.1 = 'OK'
button.2 = 'Cancel'
button.3 = 'Abort'
button.4 = 'Retry'
button.5 = 'Ignore'
button.6 = 'Yes'
button.7 = 'No'

say 'You pressed the' button.rc 'button.'