# VSPMS command aliases, last update on 12/21/88
alias lspj 'cat $MYPROJECTS'
alias chpj 'cd `wherepj \!*`;setenv PROJECT `pwd`;setenv REV NONE;dirs;source .projectrc>&/dev/null;echo $REV'
alias pushpj 'set tmp=`wherepj \!*`;pushd $tmp; setenv PROJECT `pwd`;setenv REV NONE;source .projectrc>&/dev/null;echo $REV'
alias poppj 'popd;setenv PROJECT `pwd`;setenv REV NONE;source .projectrc>&/dev/null;echo $REV'
alias pjenv 'echo Project $PROJECT, Revision $REV;echo Project table is $MYPROJECTS;echo -n "Directory stack is:  ";dirs'
alias swpj 'pushpj'
