# VSPMS command aliases

#initial values
#(we test environment vars in case this file is re-sourced during a session,
# or user overrides defaults):
if !($?PROJECT)		setenv PROJECT ~
if !($?SBPJ)		setenv SBPJ .
if !($?REV)		setenv REV ""
if !($?MAKEMF_LIB)	setenv MAKEMF_LIB /usr/local/lib/makemf
#this is the file where we store the project environment for a single
#login session.  should set to /tmp/pjenv$$ if you want to have multiple
#login sessions going:
if !($?PROJECT_ENV)	setenv PROJECT_ENV /tmp/pjenv.$USER
#base save file on hostname, for nfs mounted home dir:
if !($?PROJECT_SAVE)	setenv PROJECT_SAVE ~/.pjenv.`hostname`
alias rmpjenv /bin/rm -f $PROJECT_ENV
alias pjsave '/bin/rm -f $PROJECT_SAVE;/bin/mv $PROJECT_ENV $PROJECT_SAVE>&/dev/null'
#NOTE (pjout): if the exit fails (due to suspended jobs), then do not repeat
#pjout command or PROJECT_SAVE file will be trashed.
alias pjout 'pjsave;exit'
#if save file doesn't exist this will create empty environment file
alias pjrestore sed -e "'"'s/;.*/>\/dev\/null/;s/^/pushd /;1s/pushd/cd/;$s/$/;pushd ~ >\/dev\/null/'"'" '$PROJECT_SAVE >! $PROJECT_ENV; source  $PROJECT_ENV;/bin/cp $PROJECT_SAVE $PROJECT_ENV;dirs'

# note the trick "echo ...>& /dev/null" used in some of the aliases.
# If ... is undefined, then the rest of the command string will not
# be executed, preventing un-sightly error messages.

alias lspj 'cat $MYPROJECTS'
alias newpjenv setenv MYPROJECTS \!^

alias pci 'echo $REV; ci -N$REV \!*'
alias pco 'echo $REV; co -r$REV \!*'

# chpj with no args will cd to the "current" project, and resource
# the current project environment.
# yes, use "wherepj !*", in case no args

alias chpj 'set tmp=(`wherepj \!*` $PROJECT); cd $tmp[1]; edpjenv del $PROJECT/$SBPJ; setenv PROJECT $tmp[1]; edpjenv set $cwd $PROJECT .; setenv MAKEMF_LIB /usr/local/lib/makemf; setenv REV ""; setenv SBPJ "."; dirs; source .projectrc>&/dev/null; echo $REV'

#note - tmp is set to `wherepj ...` so that pushd will not see args if
#none echoed, causing it to swap top two elements
# yes, use "wherepj !*", in case no args
# the "reset $sav..." is to save an "implied" subpj, i.e. if a cd is done
# prior the pushpj.

alias pushpj 'set sav=$cwd; set tmp=`wherepj \!*`; pushd $tmp; edpjenv reset $sav $PROJECT $SBPJ; set tmp=`edpjenv get $cwd`; setenv PROJECT $tmp[1]; setenv SBPJ $tmp[2]; setenv MAKEMF_LIB /usr/local/lib/makemf; setenv REV ""; source $PROJECT/.projectrc>&/dev/null; echo $REV'

alias swpj 'pushpj'

#note - poppj doesn't work with +n arg

alias poppj 'popd; edpjenv del $PROJECT/$SBPJ; set tmp=`edpjenv get $cwd`; setenv PROJECT $tmp[1]; setenv SBPJ $tmp[2]; setenv MAKEMF_LIB /usr/local/lib/makemf; setenv REV ""; source $PROJECT/.projectrc>&/dev/null; echo $REV'

alias pjenv 'echo "PROJECT:	$PROJECT";echo "SUB-PROJECT:	$SBPJ";echo "REVISION:	$REV";echo "MYPROJECTS:	$MYPROJECTS";echo "MAKEMF_LIB:	$MAKEMF_LIB";dirs'

#no args - back to the "current" subpj, which is the parent project
alias subpj 'set tmp=(\!* $SBPJ);cd $PROJECT/$tmp[1]; edpjenv del $PROJECT/$SBPJ;setenv SBPJ $tmp[1]; edpjenv set $cwd $PROJECT $SBPJ; dirs; echo $REV'

#note the -s flag to wherepj.  this causes wherepj to echo $PROJECT/!$
#unless the arg is of the +n variety
alias pushspj 'set sav=$cwd; set tmp=`wherepj -s \!*`; pushd $tmp; edpjenv reset $sav $PROJECT $SBPJ; set tmp=`edpjenv get $cwd`; if ($tmp[2] == '.') set tmp[2]=\!*; setenv SBPJ $tmp[2]; edpjenv set $cwd $PROJECT $SBPJ; echo $REV'

#note the first echo is for feedback and to prevent mangling the project
#file if no argument is provided:
alias addpj 'echo "\!^	$cwd"; echo "\!^	$cwd" >>! $MYPROJECTS'

alias swspj 'pushspj'
alias popspj 'poppj'
