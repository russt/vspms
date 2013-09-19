echo in .bash_profile

RUSST=/usr/home/russt
PATH=/usr/local/bin:$RUSST/bin:/usr/ucb:/bin:/usr/bin

if [ x$LOGIN_START = x ]; then
	#set up terminal characteristics:
	stty erase  kill 
	eval `tset -s -m 'dialup:?3a' -m ":?xterm"`
	export LOGIN_START ; LOGIN_START=no
fi

#misc. exports:
export EXINIT  ; EXINIT='set wm=0|set shell=/bin/bash|set redraw|set ai|set sw=4|set ts=4'
export HOSTNAME; HOSTNAME=`uname -n`
#PS1="${HOSTNAME}\$ "

##### VSPMS SETUP:
unset PROJECTRC
export VSPMSLIB ; VSPMSLIB=$HOME/lib
export FORTE_PORT ; FORTE_PORT=`$VSPMSLIB/whatport`
PATH="$PATH:$HOME/bin/$FORTE_PORT:$HOME/bin"

export MYPROJECTS; MYPROJECTS=$HOME/projects
export PROJECT_SAVE; PROJECT_SAVE=

if [ -r $VSPMSLIB/vspms.bash ]; then
	. $VSPMSLIB/vspms.bash
else
	echo WARNING:  VSPMS not found
fi
##### END VSPMS SETUP:

export RUSSTLIB; RUSSTLIB=$HOME/lib
if [ -r $RUSSTLIB/aliases.bash ]; then
	. $RUSSTLIB/aliases.bash
else
	echo WARNING:  aliases not found
fi

