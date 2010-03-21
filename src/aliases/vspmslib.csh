#
# vspmslib.csh - VSPMS command aliases for csh & tcsh.
# Copyright (C) 1990-2010 Russ Tremain
# This is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License, see the file COPYING.
#

setenv VSPMS_REVISION V0210b7

#initial values
#(we test environment vars in case this file is re-sourced during a session,
# or user overrides defaults):
if !($?PROJECT)		setenv PROJECT ~
if !($?SBPJ)		setenv SBPJ .
if !($?REV)			setenv REV ""
if !($?PROJECTRC)	setenv PROJECTRC '.projectrc'
if !($?PJ_TMPDIR) then
    if ( -d /var/tmp ) then
	setenv PJ_TMPDIR /var/tmp/$USER
    else if ( -d /usr/tmp ) then
	setenv PJ_TMPDIR /usr/tmp/$USER
    else
	setenv PJ_TMPDIR /tmp/$USER
    endif
    mkdir -p $PJ_TMPDIR
endif

#
#this is the file where we store the project environment for a single
#login session.
#
if !($?PROJECT_ENV)	setenv PROJECT_ENV "$PJ_TMPDIR/${USER}_pjenv.$$"

#temp file to get around problem when args to eval are too long:
if !($?PJ_TMPA)	setenv PJ_TMPA  "$PJ_TMPDIR/${USER}_tmpA.$$"

#we base the project save file on hostname, for nfs mounted home directories:
if !($?PROJECT_SAVE)	setenv PROJECT_SAVE ~/.pjenv.`hostname`

alias rmpjenv /bin/rm -f $PROJECT_ENV
alias pjsave '/bin/rm -f $PROJECT_SAVE;/bin/cp $PROJECT_ENV $PROJECT_SAVE>&/dev/null'
alias pjclean '/bin/rm -f $PROJECT_ENV $PJHOME_ALIAS $PJHOME_ENV $PJCURR_ALIAS $PJCURR_ENV $PJ_TMPA; set PJHOMEINITD=0'
alias pjout 'pjsave; pjclean; exit'
#if save file doesn't exist this will create empty environment file
alias pjrestore '/bin/rm -f $PROJECT_ENV; sed -e '"'"'s/;.*/>\/dev\/null/;s/^/pushd /;1s/pushd/cd/;$s/$/;pushd ~ >\/dev\/null/'"'" '$PROJECT_SAVE> $PROJECT_ENV; source  $PROJECT_ENV;/bin/cp $PROJECT_SAVE $PROJECT_ENV;dirs'

# note the trick "echo ...>& /dev/null" used in some of the aliases.
# If ... is undefined, then the rest of the command string will not
# be executed, preventing un-sightly error messages.

alias lspj 'wherepj -lspj'
alias newpjenv setenv MYPROJECTS \!^

# the current project environment.
# yes, use "wherepj !*", in case no args

#NOTE: hp csh requires spaces in the "set tmp=( `...` )" expression
alias chpj 'pjhomeinit; set _pjtmp=( `wherepj \!*` $PROJECT ); set _pjtmp=(`eval echo $_pjtmp`); cd $_pjtmp[1]; edpjenv del $PROJECT/$SBPJ; setenv PROJECT $_pjtmp[1]; edpjenv set $cwd $PROJECT .; setenv REV ""; setenv SBPJ "."; dirs; pjrc; echo $REV'

#note - tmp is set to `wherepj ...` so that pushd will not see args if
#none echoed, causing it to swap top two elements
# yes, use "wherepj !*", in case no args
# the "reset $sav..." is to save an "implied" subpj, i.e. if a cd is done
# prior the pushpj.

alias pushpj 'pjhomeinit; set sav=$cwd; set _pjtmp=`wherepj \!*`; set _pjtmp=(`eval echo $_pjtmp`); pushd $_pjtmp; set _pjtmp=`edpjenv get $cwd`; edpjenv reset $sav $PROJECT $SBPJ; setenv PROJECT $_pjtmp[1]; setenv SBPJ $_pjtmp[2]; setenv REV ""; pjrc; echo $REV'

alias swpj 'pushpj'

alias poppj 'pjhomeinit; popd \!*; set _pjtmp=`edpjenv get $cwd`; edpjenv del $PROJECT/$SBPJ; setenv PROJECT $_pjtmp[1]; setenv SBPJ $_pjtmp[2]; setenv REV ""; pjrc; echo $REV'

alias pjenv 'echo "PROJECT:	$PROJECT";echo "SUB-PROJECT:	$SBPJ";echo "REVISION:	$REV";echo "MYPROJECTS:	$MYPROJECTS";dirs'

#no args - back to the "current" subpj, which is the parent project
alias subpj 'pjhomeinit; set _pjtmp=( \!* $SBPJ ); cd $PROJECT/$_pjtmp[1]; edpjenv del $PROJECT/$SBPJ;setenv SBPJ $_pjtmp[1]; edpjenv set $cwd $PROJECT $SBPJ; dirs; echo $REV'

#note the -s flag to wherepj.  this causes wherepj to echo $PROJECT/!$
#unless the arg is of the +n variety
alias pushspj 'pjhomeinit; set sav=$cwd; set _pjtmp=`wherepj -s \!*`; set _pjtmp=(`eval echo $_pjtmp`); pushd $_pjtmp; set _pjtmp=`edpjenv get $cwd`; edpjenv reset $sav $PROJECT $SBPJ; if ($_pjtmp[2] == '.') set _pjtmp[2]=\!*; setenv SBPJ $_pjtmp[2]; edpjenv set $cwd $PROJECT $SBPJ; echo $REV'

#same as poppj - just in case the popped dir is not really a subpj.
alias popspj 'poppj'

alias addpj	'echo \!^	$cwd >>! $MYPROJECTS'
alias delpj	'wherepj -d \!*'

#
#home state additions, 10/6/96
#
if !($?PJHOMEINITD) set PJHOMEINITD=0
if ($?PJTESTING) echo PJHOMEINITD is $PJHOMEINITD
setenv PJHOME_ALIAS "$PJ_TMPDIR/${USER}_home_alias.$$"
setenv PJHOME_ENV "$PJ_TMPDIR/${USER}_home_env.$$"
setenv PJCURR_ALIAS "$PJ_TMPDIR/${USER}_curr_alias.$$"
setenv PJCURR_ENV "$PJ_TMPDIR/${USER}_curr_env.$$"

#
#PJENV_READONLY - list of vars to never reset when restoring home project state.
#typically, this should ONLY be variables related to the current directory,
#or variables reset by the chpj alias (such as REV).
#
set _pjtmp="PWD,PROJECT,SBPJ,REV,MYPROJECTS"
if ($?PJENV_READONLY) then
	#if defined and non-standard...
	if ($_pjtmp != $PJENV_READONLY) then
		#...include user additions:
		setenv PJENV_READONLY "$_pjtmp,$PJENV_READONLY"
	endif
else
	setenv PJENV_READONLY "$_pjtmp"
endif
unset _pjtmp

#
#development note:
#	this alias gave me much difficulty, primarily due
#	to 'noclobber' setting - if noclobber set, i/o redirection (via >!)
#	of setenv & alias commands is unreliable.  use rm -f instead.
#
alias pjhomeinit 'unset _pjtmp && if !($PJHOMEINITD) eval "/bin/rm -f $PJHOME_ENV $PJHOME_ALIAS; env> $PJHOME_ENV; alias> $PJHOME_ALIAS; set PJHOMEINITD=1"'
alias pjsavecurr	'/bin/rm -f $PJCURR_ENV $PJCURR_ALIAS; env> $PJCURR_ENV; alias> $PJCURR_ALIAS'

alias pjrestorehome	'pjsavecurr; /bin/rm -f $PJ_TMPA; homepj > $PJ_TMPA; source $PJ_TMPA'
alias pjrc	'pjrestorehome; pjsetprompt; if (-r $PROJECT/$PROJECTRC) source $PROJECT/$PROJECTRC'

set xx="`alias setprompt`"
if ("$xx" != "") then
	alias pjsetprompt setprompt
else
	#this is a no-op
	alias pjsetprompt ';'
endif

unset xx
alias pjresethome 'set PJHOMEINITD=0; pjhomeinit'

alias pjawk awk
foreach dir ( $path )
	#echo looking in $dir
	if ( -x $dir/nawk ) then
		alias pjawk $dir/nawk
		#echo found in `alias pjawk`
		break
	else if ( -x $dir/gawk ) then
		alias pjawk $dir/gawk
		#echo found in `alias pjawk`
		break
	endif
end

alias pjname 'wherepj -lspj |&' pjawk "'"'$2 ~ ("^" ENVIRON["PROJECT"] "$") { print $1; exit 0 }'"'"
