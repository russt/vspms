# VSPMS command aliases

# note the trick "echo ...>& /dev/null" used in some of the aliases.
# If ... is undefined, then the rest of the command string will not
# be executed, preventing un-sightly error messages.

alias lspj 'cat $MYPROJECTS'
alias newpjenv setenv MYPROJECTS \!^

alias pci 'echo $REV; ci -N$REV \!*'
alias pco 'echo $REV; co -r$REV \!*'

# note the arg to cd has the effect of not changing the
# current directory (cd thinks it has an arg), which will re-source
# the current project environment.
alias chpj 'cd `wherepj \!*`;setenv PROJECT `pwd`;setenv MAKEMF_LIB /usr/local/lib/makemf;setenv REV NONE;setenv SUBPROJ NONE;dirs;source .projectrc>&/dev/null;echo $REV'

# The cd $PROJECT pops any sub-project context.  A subsequent swpj will
# thus restore the correct project context.  The downside is you have to
# do a chpj before pushpj will work.

alias pushpj 'cd $PROJECT;set tmp=`wherepj \!*`;pushd $tmp; setenv PROJECT `pwd`;setenv MAKEMF_LIB /usr/local/lib/makemf;setenv REV NONE;setenv SUBPROJ NONE;source .projectrc>&/dev/null;echo $REV'

alias swpj 'pushpj'

alias poppj 'popd;setenv PROJECT `pwd`;setenv MAKEMF_LIB /usr/local/lib/makemf;setenv REV NONE;setenv SUBPROJ NONE;source .projectrc>&/dev/null;echo $REV'

alias pjenv 'echo Project $PROJECT, Sub-Project $SUBPROJ, Revision $REV;echo Project list:  $MYPROJECTS;echo Makemf library: $MAKEMF_LIB;echo -n "Project stack:  ";dirs'

alias subpj 'setenv SUBPROJ \!^;cd $PROJECT/$SUBPROJ;dirs;echo $REV'

#note the -s flag to wherepj
alias pushspj 'set tmp=`wherepj -s \!*`;pushd $tmp;set tmp=`pwd`;setenv SUBPROJ $tmp:t;echo $REV'

alias swspj 'pushspj'

alias popspj 'popd;set tmp=`pwd`;setenv SUBPROJ $tmp:t;echo $REV'
