#
#this is the unix korn-shell version.  note sure if it works on mks.
#
export DIRSTACK; DIRSTACK=${DIRSTACK:-$HOME}
alias dirs='echo $DIRSTACK'
unset -f cd CD pushd popd
alias cd=CD

alias resetdirs='DIRSTACK=$PWD'

function CD
{
	'cd' $*
	if (( $? )); then return 1; fi

	typeset stack
	set -A stack $DIRSTACK
	stack[0]=$PWD
	DIRSTACK="${stack[*]}"
}

function pushd
{
	if [[ $1 = ++([0-9]) ]]; then
		typeset stack
		set -A stack $DIRSTACK

		# case of pushd +n: rotate n-th directory to top
		let num=${1#+}

		#have to be at least num:
		if (( ${#stack[*]} <= $num )); then
			print pushd: Directory stack not that deep.
			return 1
		fi
		typeset top; top=${stack[$num]}

		'cd' $top
		if (( $? )); then return 1; fi

		stack[$num]=""
		DIRSTACK="$top ${stack[*]}"
	elif [[ -z $1 ]]; then
		# no args - swap top 2 dirs...
		typeset stack
		set -A stack $DIRSTACK

		#have to be at least two:
		if (( ${#stack[*]} < 2 )); then
			print pushd: No other directory.
			return 1
		fi
		typeset top; top=${stack[1]}

		'cd' $top
		if (( $? )); then return 1; fi

		stack[1]=${stack[0]}
		stack[0]=$top
		DIRSTACK="${stack[*]}"
	else
		# normal case of pushd dirname
		dirname=$1
		if [[ -d $dirname && -x $dirname ]]; then
			'cd' $dirname
			if (( $? )); then return 1; fi
			DIRSTACK="$dirname $DIRSTACK"
		else
			if [[ ! -a $dirname ]]; then
				print ${dirname}: No such file or directory
			elif [[ ! -d $dirname ]]; then
				print ${dirname}: Not a directory
			elif [[ ! -x $dirname ]]; then
				print ${dirname}: Not accessible
			fi
			return 1
		fi
	fi
	#dirs
	echo $DIRSTACK
}

function popd
# pop directory off the stack, cd to new top
{
	typeset stack
	set -A stack $DIRSTACK

	if [[ $1 = ++([0-9]) ]]; then
		# case of popd +n: delete n-th directory
		let num=${1#+}

		#have to be at least num:
		if (( ${#stack[*]} <= $num )); then
			print popd: Directory stack not that deep.
			return 1
		fi

		stack[$num]=""
		DIRSTACK="${stack[*]}"
	else
		#popd without argument
		if (( ${#stack[*]} < 2 )); then
			print popd: Directory stack not that deep.
			return 1
		fi

		typeset top
		top=${stack[1]}
		stack[0]=""
		DIRSTACK="${stack[*]}"
		cd $top
	fi
	#dirs
	echo $DIRSTACK
}
