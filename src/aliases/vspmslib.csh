# VSPMS command aliases

#this is the filename used to store the project environment for a single
#login session.  It should be removed upon logout

#initial values
#(we test project, sub-project vars in case this file is
# re-sourced during a session):
if !($?PROJECT) setenv PROJECT ~
if !($?SBPJ) setenv SBPJ .
if !($?REV) setenv REV ""
setenv PROJECT_ENV /tmp/pjenv$$
# this can be overridden prior to sourcing this file
if !($?PROJECT_SAVE) setenv PROJECT_SAVE ~/.pjenv
alias rmpjenv /bin/rm -f $PROJECT_ENV
alias pjout 'pjsave;exit'
alias pjsave '/bin/rm -f $PROJECT_SAVE;/bin/mv $PROJECT_ENV $PROJECT_SAVE>&/dev/null'
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
alias pushspj 'set sav=$cwd; set tmp= `wherepj -s \!*`; pushd $tmp; edpjenv reset $sav $PROJECT $SBPJ; edpjenv set $cwd $PROJECT $tmp; echo $REV'

alias swspj 'pushspj'

alias popspj 'poppj'
