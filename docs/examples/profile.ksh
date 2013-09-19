#exporting ENV has the following semantics:
#	1.  $ENV file will be executed at .profile time, but only once.
#	    (subsequent executions of .profile will not re-execute $ENV file.)
#	2.  any subsequent ksh command file will execute and inherit from $ENV file.
#	3.  this is similar to .cshrc/.login in csh, except the $ENV file
#	    is executed after .profile instead of before.
#
export ENV; ENV=$HOME/kshrc.ksh

PATH=:/usr/ucb:/bin:/usr/bin
#set up terminal characteristics:
set noglob; eval `tset -s -m 'dialup:?3a' -m ":?vtruss"`; set glob
stty crterase crtkill intr  erase  kill  rows 32 columns 104
set -o vi
