#
#this is a posix shell version, that was developed for mks-toolkit originally.
#
export DIRSTACK; DIRSTACK=${DIRSTACK:-$HOME}
alias dirs='echo $DIRSTACK'
unset -f cd CD pushd popd
alias cd=CD

alias resetdirs='DIRSTACK=$PWD'

function CD
{
	'cd' $*
	if [ $? -ne 0 ]; then return 1; fi

	typeset stack
	set -A stack $DIRSTACK
	stack[0]=$PWD
	DIRSTACK="${stack[*]}"
}

function pushd
{
#echo T0 arg is .$1.
	#convoluted way of saying if $1 ~ /^+[1-9]/
	if [ "$1" != "" -a "${1#+[1-9]}" = "" ]; then
#echo T1
		typeset stack
		set -A stack $DIRSTACK

		# case of pushd +n: rotate n-th directory to top
		num=${1#+}

		#have to be at least num:
		if [ ${#stack[*]} -le $num ]; then
			print pushd: Directory stack not that deep.
			return 1
		fi
		typeset top; top=${stack[$num]}

		'cd' $top
		if [ $? -ne 0 ]; then
		    return 1
		fi

		stack[$num]=""
		DIRSTACK="$PWD ${stack[*]}"
	elif [ -z $1 ]; then
#echo T5
		# no args - swap top 2 dirs...
		typeset stack
		set -A stack $DIRSTACK

		#have to be at least two:
		if [ ${#stack[*]} -lt 2 ]; then
			print pushd: No other directory.
			return 1
		fi
		typeset top; top=${stack[1]}

		'cd' $top
		if [ $? -ne 0 ]; then
		    return 1
		fi

		stack[1]=${stack[0]}
		stack[0]=$PWD
		DIRSTACK="${stack[*]}"
	else
#echo T7
		# normal case of pushd dirname
		dirname=$1
		if [ -d $dirname -a -x $dirname ]; then
			'cd' $dirname
			if [ $? -ne 0 ]; then
			    return 1
			fi
			DIRSTACK="$PWD $DIRSTACK"
		else
			if [ ! -a $dirname ]; then
				print ${dirname}: No such file or directory
			elif [ ! -d $dirname ]; then
				print ${dirname}: Not a directory
			elif [ ! -x $dirname ]; then
				print ${dirname}: Not accessible
			fi
			return 1
		fi
	fi
#echo T10
	dirs
}

function popd
# pop directory off the stack, cd to new top
{
	typeset stack
	set -A stack $DIRSTACK

#echo T0 stack=$stack

	if [ "$1" != "" -a "${1#+[1-9]}" = "" ]; then
#echo T3
		# case of popd +n: delete n-th directory
		num=${1#+}

#echo T4 num = $num
		#have to be at least num:
		if [ ${#stack[*]} -le $num ]; then
			print popd: Directory stack not that deep.
			return 1
		fi

		stack[$num]=""
		DIRSTACK="${stack[*]}"
	else
#echo T5
		#popd without argument
		if [ ${#stack[*]} -lt 2 ]; then
			print popd: Directory stack not that deep.
			return 1
		fi

		typeset top
		top=${stack[1]}
		stack[0]=""
		DIRSTACK="${stack[*]}"
		cd $top
	fi
	dirs
}
