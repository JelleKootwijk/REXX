/* commandOutput.rex

  the commandOutput program is
  an external procedure.

  the program performs a command
  which is passed as the argument.
  command output lines are gathered
  into a single string value.

  this program is very convenient
  when the output of a command is
  a single line.
*/

newstack

''arg(1) '(stack'

commandOutput = ''

do queued()
  parse pull qline
  commandOutput = commandOutput || copies( '0a'x, length( commandOutput ) > 0 ) || qline
  end

delstack

return commandOutput