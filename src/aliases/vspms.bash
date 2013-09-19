export PROJECTRC   ; PROJECTRC=${PROJECTRC:-./projectrc.bsh}
export PROJECT     ; PROJECT=${PROJECT:-~}
export SBPJ        ; SBPJ=${SBPJ:-.}
export REV         ; REV=${REV:-}
export MAKEMF_LIB  ; MAKEMF_LIB=${MAKEMF_LIB:-/usr/local/lib/makemf}
#NOTE - TMPDIR is defined by mks.
export TMPDIR ; TMPDIR=${TMPDIR:-/tmp}
export PROJECT_ENV ; PROJECT_ENV=${PROJECT_ENV:-$TMPDIR/pjenv.$$}
export MYPROJECTS ; MYPROJECTS=${MYPROJECTS:-$HOME/myprojects}

export HOSTNAME    ; HOSTNAME=${HOSTNAME:-$(uname -n)}
export PROJECT_SAVE; PROJECT_SAVE=${PROJECT_SAVE:-$HOME/.pjenv_ksh.$HOSTNAME}

alias rmpjenv='rm -f $PROJECT_ENV; PROJECT=$PWD; SBPJ=.; REV='
alias pjsave='rm -f $PROJECT_SAVE; cp $PROJECT_ENV $PROJECT_SAVE 2> /dev/null'
alias pjout='pjsave;exit'

alias lspj='wherepj -lspj'
alias pjenv='echo "PROJECT:	$PROJECT";echo "SUB-PROJECT:	$SBPJ";echo "REVISION:	$REV";echo "MYPROJECTS:	$MYPROJECTS";echo "MAKEMF_LIB:	$MAKEMF_LIB";dirs'

unset -f pjrestore
function pjrestore
{
	'sed' -e 's|;.*|>/dev/null|; s|^|pushd |; 1s|pushd|cd|; $s|$|;pushd ~ >/dev/null|' $PROJECT_SAVE > $PROJECT_ENV
	.  $PROJECT_ENV
	'cp' $PROJECT_SAVE $PROJECT_ENV;
	dirs
}

unset -f delpj
function delpj
{
	if [ -z $1 ]; then
		echo "Usage:  delpj project_name"
		echo "	deletes <project_name>"
		return 0
	fi

	'grep' -s  "^${1}[ 	]" ${MYPROJECTS}
	if [ $? -eq 0 ] ; then
		'grep' -v "^${1}[ 	]" ${MYPROJECTS} > /tmp/vspm$$
		cp /tmp/vspm$$ $MYPROJECTS
	else
		echo "not found, $1"
	fi
	rm -f /tmp/vspms$$
}

unset -f addpj
function addpj
{
	if [ -z $1 ]; then
		echo "Usage:  addpj project_name"
		echo "	adds current directory as <project_name>"
		return 0
	fi
	echo "$1	$PWD" >> $MYPROJECTS
	echo "$1	$PWD"
}

unset -f newpjenv
function newpjenv
{
	if [ -z $1 ]; then
		echo "Usage:  newpjenv newfile"
		echo "	changes project index file to <newfile>"
		return 0
	fi
	MYPROJECTS="$1"
}

unset -f chpj
function chpj
{
	typeset tmp

	tmp=$(wherepj $*)
	if [ $? -ne 0 ]; then return 1; fi
	if [ -z $tmp ]; then tmp=$PROJECT; fi

	#without this, ~ & ~user does not expand:
	tmp=$(eval "echo $tmp")

#echo tmp is $tmp >> /tmp/pjdebug

	cd $tmp
	if [ $? -ne 0 ]; then return 1; fi

	edpjenv del $PROJECT/$SBPJ
	PROJECT=$tmp
	edpjenv set $PWD $PROJECT .
	MAKEMF_LIB=/usr/local/lib/makemf
	REV=""
	SBPJ="."
	dirs
	if [ -f $PROJECTRC ]; then . $PROJECTRC; fi
	if [ -n $REV ]; then echo $REV; fi
}

unset -f pushpj 
function pushpj 
{
	typeset tmp
	typeset sav

	sav=$PWD
	tmp=$(wherepj $*)
	if [ $? -ne 0 ]; then return 1; fi

	#without this, ~ & ~user does not expand:
	tmp=$(eval "echo $tmp")

	pushd $tmp
	if [ $? -ne 0 ]; then return 1; fi

	edpjenv reset $sav $PROJECT $SBPJ
	tmp=($(edpjenv get $PWD))
echo tmp is ${tmp[*]} >> /tmp/pjdebug
	PROJECT=${tmp[0]}
	SBPJ=${tmp[1]}
	MAKEMF_LIB=/usr/local/lib/makemf
	REV=""

	if [ -f $PROJECT/$PROJECTRC ]; then . $PROJECT/$PROJECTRC; fi
	if [ -n $REV ]; then echo $REV; fi
}

unset -f poppj 
function poppj 
{
	typeset tmp

	popd $*
	if [ $? -ne 0 ]; then return 1; fi

	tmp=($(edpjenv get $PWD))
	edpjenv del $PROJECT/$SBPJ

	PROJECT=${tmp[0]}
	SBPJ=${tmp[1]}
	edpjenv set $PWD $PROJECT $SBPJ
	MAKEMF_LIB=/usr/local/lib/makemf
	REV=""

	if [ -f $PROJECT/$PROJECTRC ]; then . $PROJECT/$PROJECTRC; fi
	if [ -n $REV ]; then echo $REV; fi
}

unset -f subpj
function subpj
{
	typeset tmp

	tmp="${1:-$SBPJ}"
	cd "$PROJECT/$tmp"
	if [ $? -ne 0 ]; then return 1; fi

	edpjenv del $PROJECT/$SBPJ

	SBPJ=$tmp
	edpjenv set $PWD $PROJECT $SBPJ

	dirs
	if [ -n $REV ]; then echo $REV; fi
}

unset -f pushspj
function pushspj
{
	typeset sav
	sav=$PWD
	if [ $# -gt 0 -a -d $PROJECT/$1 ]; then
		pushd $PROJECT/$1
		if [ $? -ne 0 ]; then
			echo pushspj: $PROJECT/$SBPJ not accessible
			return 1
		fi
		edpjenv reset $sav $PROJECT $SBPJ
		SBPJ=$1
		edpjenv set $PWD $PROJECT $SBPJ
		if [ -n $REV ]; then echo $REV; fi
		return 0
	fi

	#otherwise, +n form:
	pushd $*
	if [ $? -ne 0 ]; then
		echo pushspj: pushd $* failed.
		return 1
	fi
	edpjenv reset $sav $PROJECT $SBPJ
	tmp=($(edpjenv get $PWD))

	if [ ${tmp[0]} != $PROJECT ]; then
		PROJECT=${tmp[0]}
		SBPJ=${tmp[1]}
#echo new pjenv PROJECT=$PROJECT SBPJ=$SBPJ
		edpjenv set $PWD $PROJECT $SBPJ

		#restore old project env:
		REV=
		MAKEMF_LIB=
		if [ -f $PROJECT/$PROJECTRC ]; then
			.  $PROJECT/$PROJECTRC
		fi
	else
		SBPJ=${tmp[1]}
#echo restored pjenv PROJECT=$PROJECT SBPJ=$SBPJ
		edpjenv set $PWD $PROJECT $SBPJ
	fi

	if [ -n $REV ]; then echo $REV; fi
}

unset -f popspj 
function popspj 
#same as poppj except don't exec PROJECTRC
{
	typeset tmp

	popd $*
	if [ $? -ne 0 ]; then return 1; fi

	edpjenv del $PROJECT/$SBPJ
	tmp=($(edpjenv get $PWD))

	SBPJ=${tmp[1]}
	if [ -n $REV ]; then echo $REV; fi
}
# alias pushspj '
# set sav=$cwd
# set tmp=`wherepj -s \!*`
# pushd $tmp
# edpjenv reset $sav $PROJECT $SBPJ
# set tmp=`edpjenv get $cwd`
# if ($tmp[2] == '.') set tmp[2]=\!*
# setenv SBPJ $tmp[2]
# edpjenv set $cwd $PROJECT $SBPJ
# echo $REV'
# 

#Project aliases:
alias swpj='pushpj'

#Sub-Project aliases:
alias swspj='pushspj'
alias popspj='poppj'

