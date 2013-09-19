print Executing kshrc HOME is $HOME

RUSSTLIB=$HOME/lib
PATH=$MAINROOT/tools/bin/cmn:/usr/local/bin:$HOME/bin:/usr/ucb:/bin:/usr/bin
export FORTE_PORT; FORTE_PORT=`whatport`
PATH=".:$HOME/bin/$FORTE_PORT:$MAINROOT/tools/bin/$FORTE_PORT:$PATH"


#NOTE:  can define mult. functions in one file, but must call the
#filename to read in all functions. WRONG!.  Only worked because
#I had already read in the functions.

#function library path:
#export FPATH; FPATH=$HOME/lib/ksh
#autoload $FPATH/*

#misc. exports:
export EXINIT  ; EXINIT='set wm=0|set shell=/bin/csh|set redraw|set ai|set sw=4|set ts=4'
export HOSTNAME; HOSTNAME=$(hostname)

alias rekshrc='. $ENV'
alias realias='. $RUSSTLIB/aliases.ksh'
alias repushd='. $RUSSTLIB/pushd.ksh'
alias revspms='. $RUSSTLIB/vspms.ksh'
alias logout='. $RUSSTLIB/logout.ksh'

realias
repushd

export MYPROJECTS; MYPROJECTS=~/projects
export PROJECT_SAVE; PROJECT_SAVE=
#revspms
