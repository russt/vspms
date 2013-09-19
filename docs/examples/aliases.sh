ll() ls -lF $*
la() ls -aF $*
lg() ls -lgF $*
g() grep $*
m() more $*
j() jobs
source() . $1
pd() pushd $*
pp() pushpj $*
s() subpj $*
pspj() pushspj $*
realias() . $RUSSTLIB/aliases.sh
repushd() . $RUSSTLIB/pushd.sh
revspms() . $RUSSTLIB/vspms.sh
logout() . $RUSSTLIB/logout.sh
reprofile() . $HOME/.profile
