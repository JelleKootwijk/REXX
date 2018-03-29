/* rexxtry.rex, a bare bones interpreter

 Keywords
  REXX statement experimentation, INTERPRET example,
  Interactive command shell

 Usage
  r4 rexxtry

 Arguments
  None

 Files used
  Console immediate input and output

 Exit codes
   0   => last request was successful
 non-0 => last return code

 Input record format
  Input is read as normal console input.

 Sample input file
  N/A

 Sample output file
  An output file is not produced, but a sample session follows:
  ��������������������������������������������������������������������͸
  � 'EXIT' to end                                                      �
  � Yes, swami?     time                              [MS-DOS command] �
  � Current time is 22:32:59.43                ["time" command output] �
  � Enter new time: <CR>                                               �
  �                                                                    �
  � Yes, swami?     do 6; say random( 1, 49 ); end    [statement loop] �
  � 41                                                                 �
  � 27                                                                 �
  � 38                                                                 �
  � 7                                                                  �
  � 16                                                                 �
  � 31                                                                 �
  � Yes, swami?     EXIT                                               �
  ��������������������������������������������������������������������;

 Example of use
  r4 rexxtry


 Explanation
  This procedure is an interactive REXX statement execution shell. A
  prompt is displayed for entry 1 or more REXX statements. The user's
  response is INTERPRETed. Statements can perform any REXX statement,
  including loops, references to built-in functions, external procedure
  calls, and system command initiation. There are special concerns which
  must be met when loops are coded [refer to Cowlishaw(1985) page 49].
  Output from statements is processed normally.

  When erroneous requests are encountered, a message is displayed showing
  the erroneous line, and processing resumes with another prompt.

  Processing is terminated by typing "EXIT" or "RETURN" statements, or
  by hitting either Control-Break or Control-C.
*/

prompt = "==> "

RC = 0                                                /* presume no errors */

call on halt

call lineout !, "Type 'EXIT' to end"                   /* show how to stop */

resume :                   /* resumption point after erroneous expressions */

signal on error; signal on failure; signal on syntax; /* anticipate errors */

call charout !, date() time() prompt       /* solicit initial REXX request */

do until lines(!) <= 0      /* process requests until end of console input */

  parse value linein(!) with _line_                    /* get REXX request */

  if _line_ == "thanks" then         /* answer unexpected praise from user */
    call lineout !, "...Your wish is my command"          /* show humility */

  else
    interpret _line_                        /* INTERPRET REXX statement(s) */

  call charout !, date() time() prompt        /* solicit next REXX request */

  end

exit RC                                   /* final code is returned upward */

error: failure: syntax:                    /* deal with erroneous requests */
  call lineout !, "???" condition( 'D' ) "07"x /* show befuddlement & beep */
  call lineout !, "  " _line_                    /* show erroneous request */
  signal resume                                       /* resume processing */

halt : procedure
  exit 0