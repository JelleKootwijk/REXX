@echo off
rem
rem replaces 'more' with 'revu' !
rem
rem usage: cmds | !! Shazam
cat > %tmp%\_%1.txt
start revu %tmp%\_%1.txt