#exporting ENV has the following semantics:
#	1.  $ENV file will be executed at .profile time, but only once.
#	    (subsequent executions of .profile will not re-execute $ENV file.)
#	2.  any subsequent ksh command file will execute and inherit from $ENV file.
#	3.  this is similar to .cshrc/.login in csh, except the $ENV file
#	    is executed after .profile instead of before.
#
#echo in .profile

RUSST=/usr/home/russt
PATH=/usr/local/bin:$RUSST/bin:/usr/ucb:/bin:/usr/bin:${PATH}

if [ x$LOGIN_START = x ]; then
	#set up terminal characteristics:
	stty erase  kill 
	eval `tset -s -m 'dialup:?3a' -m ":xterm"`
	export LOGIN_START ; LOGIN_START=no
fi

#### ksh stuff
#unset ENV
#export ENV; ENV=$HOME/lib/kshrc.ksh
#e.g., function library path:
#export FPATH; FPATH=$HOME/lib/ksh
#autoload $FPATH/*
#set -o vi

#misc. exports:
export EXINIT  ; EXINIT='set wm=0|set shell=/bin/csh|set redraw|set ai|set sw=4|set ts=4'
export HOSTNAME; HOSTNAME=`uname -n`
PS1="${HOSTNAME}\$ "

export RUSST ; RUSST=$HOME
export RUSSTLIB ; RUSSTLIB=$RUSST/lib
export FORTE_PORT=`$RUSSTLIB/whatport`
PATH="$PATH:$RUSST/bin/$FORTE_PORT:$RUSST/bin"

if [ -r $RUSSTLIB/pushd.ksh ]; then
	. $RUSSTLIB/pushd.ksh
else
	echo WARNING:  pushd package not found
fi

export MYPROJECTS; MYPROJECTS=~/projects
export PROJECT_SAVE; PROJECT_SAVE=

if [ -r $RUSSTLIB/vspms.ksh ]; then
	. $RUSSTLIB/vspms.ksh
else
	echo WARNING:  VSPMS not found
fi

if [ -r $RUSSTLIB/aliases.ksh ]; then
	. $RUSSTLIB/aliases.ksh
else
	echo WARNING:  aliases not found
fi

