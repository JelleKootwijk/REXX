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
  ีออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออธ
  ณ 'EXIT' to end                                                      ณ
  ณ Yes, swami?     time                              [MS-DOS command] ณ
  ณ Current time is 22:32:59.43                ["time" command output] ณ
  ณ Enter new time: <CR>                                               ณ
  ณ                                                                    ณ
  ณ Yes, swami?     do 6; say random( 1, 49 ); end    [statement loop] ณ
  ณ 41                                                                 ณ
  ณ 27                                                                 ณ
  ณ 38                                                                 ณ
  ณ 7                                                                  ณ
  ณ 16                                                                 ณ
  ณ 31                                                                 ณ
  ณ Yes, swami?     EXIT                                               ณ
  ิออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออพ

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