# VSPMS command aliases

#this is the filename used to store the project environment for a single
#login session.  It should be removed upon logout

setenv PROJECT_ENV /tmp/pjenv$$
alias rmpjenv /bin/rm -f $PROJECT_ENV
alias exit "rmpjenv;exit"
alias logout "rmpjenv;logout"

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

alias chpj 'set tmp=(`wherepj \!*` $cwd); setenv PROJECT $tmp[1]; edpjenv del $cwd; cd $PROJECT; setenv MAKEMF_LIB /usr/local/lib/makemf; setenv REV ""; setenv SBPJ ""; dirs; source .projectrc>&/dev/null; echo $REV'

#note - tmp is set to `wherepj ...` so that pushd will not see args if
#none echoed, causing it to swap top two elements
# yes, use "wherepj !*", in case no args

alias pushpj 'set tmp=`wherepj \!*`; pushd $tmp; set tmp=`edpjenv get $cwd`; setenv PROJECT $tmp[1]; setenv SBPJ $tmp[2]; setenv MAKEMF_LIB /usr/local/lib/makemf; setenv REV ""; source $PROJECT/.projectrc>&/dev/null; echo $REV'

alias swpj 'pushpj'

#note - poppj doesn't work with +n arg

alias poppj 'edpjenv del $cwd; popd; set tmp=`edpjenv get $cwd`; setenv PROJECT $tmp[1]; setenv SBPJ $tmp[2]; setenv MAKEMF_LIB /usr/local/lib/makemf; setenv REV ""; source $PROJECT/.projectrc>&/dev/null; echo $REV'

alias pjenv 'echo Project $PROJECT, Sub-Project $SBPJ, Revision $REV;echo Project list:  $MYPROJECTS;echo Makemf library: $MAKEMF_LIB;echo -n "Project stack:  ";dirs'

#no args - change to the "home" subpj, which is the parent project
alias subpj 'edpjenv del $cwd; setenv SBPJ "\!*"; cd $PROJECT/$SBPJ; edpjenv set $cwd $PROJECT $SBPJ; dirs; echo $REV'

#note the -s flag to wherepj.  this causes wherepj to echo $PROJECT/!$
#unless the arg is of the +n variety
alias pushspj 'set tmp= `wherepj -s \!*`; pushd $tmp; edpjenv set $cwd $PROJECT $tmp; echo $REV'

alias swspj 'pushspj'

alias popspj 'poppj'
