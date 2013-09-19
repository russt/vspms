umask 002
set time=1
unset autologout

if !($?HOME) then
    if ($?home) then
        setenv HOME $home
    else
        setenv HOME ~
    endif
endif

if ("$HOME" == "") then
    echo ERROR - HOME NOT SET
    setenv HOME NULL
endif

if !($?USER) then
    if ($?user) then
        setenv USER $user
    else if ("$HOME" != "") then
        setenv USER `basename $HOME`
    endif
endif

if ("$USER" == "") then
    echo ERROR - USER NOT SET
    setenv USER NULL
endif

id | grep root >& /dev/null
if !($status) then
    set IAMROOT = 1
else
    set IAMROOT = 0
endif

#note - missing dirs will be eliminated later by optpath.
set path=(. $HOME/bin /opt/csw/bin /opt/SUNWspro/bin /usr/local/bin /usr/ucb /bin /usr/bin \
    /usr/local/sbin /usr/ccs/bin /usr/sfw/bin /etc /usr/etc /usr/sadm/bin \
    /usr/bin/X11 /usr/lang /pub/bin /usr/sbin /usr/openwin/bin )

unalias *
if !($?HOSTNAME) then
    setenv HOSTNAME `uname -n`
endif

setenv HOST $HOSTNAME

if (-x $HOME/lib/whatport) then
    setenv PRT `$HOME/lib/whatport`
    if ($PRT == "unknown") then
        if ($?prompt) then
            echo WARNING this machine is unknown to whatport
        endif
    endif
else
    setenv PRT NULL
endif

setenv MANPATH "/opt/csw/man:/usr/sfw/man:/usr/local/man:$HOME/man:/usr/man:/usr/share/man"

if (-d /usr/catman) then
    setenv MANPATH "${MANPATH}:/usr/catman"
endif

if (! $?TZ ) then
    setenv TZ PST8PDT
    #echo WARNING - defaulting TZ to $TZ
endif

setenv PAGER more
setenv EDITOR vi
setenv MAILER Mail

#set up filename completion
set filec
#if starts with ., => *.
set fignore = ( CVS RCS .o .class )

alias yymmdd "date  '+%y%m%d'"

#if setprompt is defined, will be executed by the standard fortepj.rc file:
if ($IAMROOT) then
    alias setprompt 'set prompt="${HOSTNAME}{`pjname` \!}# "'
else
    alias setprompt 'set prompt="${HOSTNAME}{`pjname` \!} "'
endif

set history=500
# a note about argument selectors in aliases:
#   \!* ==  all arguments
#   \!^ ==  first argument
#   \!$ ==  last argument
#   \!*-    ==  all but last argument
#   \!*-2   ==  first and second arg.
#   \!:n    ==  nth arg.
#   \!:n-   ==  nth thru all but last arg
#   \!:n-$  ==  nth thru last arg
alias ls ls -F
alias la ls -a
alias ll ls -l
alias lll ls -lL
alias m more
alias g grep
alias j jobs
alias h history
alias j jobs

### dec/hex converions.  note that dc wants uppercase hex digits:
alias hextodec 'echo 16i \!$ p | tr a-f A-F |dc'
alias dectohex 'echo 16o \!$ p |dc | tr A-F a-f'

alias setminus 'comm -23 \!*'
alias toupper "tr '[a-z]' '[A-Z]'"
alias tolower "tr '[A-Z]' '[a-z]'"
alias dos2unix "tr -d '\015' < \!*"
alias unixpath "echo \!* | sed 's.:./.g'"

alias hhmmss "date  '+%H%M%S'"
alias yymmddhhmm "date '+%y%m%d%H%M'"
alias txtime "date  '+%Y%m%d%H%M%S'"
alias unixtime perl -e "'"'{printf "%d\n", time;}'"'"
alias gmttime perl -e "'"'@T = gmtime(time); printf "%04d%02d%02d%02d%02d%02d\n",$T[5]+1900,$T[4]+1,$T[3],$T[2],$T[1],$T[0];'"'"
alias gmtdate '(setenv TZ GMT; date)'

### Note - this depends on gnu version of uniq
alias dupcase 'sort -f \!* | uniq -Di'

alias mmf   makemf -o Makefile -f make.mmf
alias onecol perl -n -a -F"'"'/\s+|:|;/'"'" -e "'"'{for (@F) {print "$_\n";}}'"'"
alias addplus perl -n -e "'"'{printf "+%d %s", $ii++, $_;}'"'"
alias pdirs 'dirs|onecol|addplus'

alias whattools 'cat $TOOLROOT/boot/CVS/Root'
alias showtoolsrepos 'echo using tools from `whattools`'
alias toolsfrom showtoolsrepos

#linux aliases:
alias lsrpm 'rpm -q -l -p \!^'

if ( -x /bin/vim || -x /usr/bin/vim || -x /opt/csw/bin/vim || -x /usr/local/bin/vim ) then
    alias vi vim
endif

#   \!* ==  all arguments
alias lsdate "/bin/ls -l \!* | sed -e 's/  */ /g' | cut -f6- -d' '"
#for run<product>Build scripts:
alias checkbuild 'checkpid -v $SRCROOT/regress/.runbldpid'
alias recycle 'mv ../trash ../trash.old ; mkdir ../trash ; mv ../trash.old ../trash'

if ( $?SYSTEMROOT ) then
    setenv HOSTFILE `cygpath -u $SYSTEMROOT`/system32/drivers/etc/hosts
    alias vihosts 'vi $HOSTFILE'
else
    setenv HOSTFILE /etc/hosts
    #alias vihosts 'sudo vi $HOSTFILE'
    alias vihosts 'vi $HOSTFILE'
endif

set opt=`optpath` >& /dev/null
if ($status == 0 && $opt != "") then
    setenv PATH $opt
else
    echo path not optimized
endif

### VSPMS aliases:
alias s subpj
alias pp    pushpj
alias pspj  pushspj

set VSPMSHOME=~                                                      #VSPMS
set VSPMSLIB=$VSPMSHOME/lib                                    #VSPMS
if (-r $VSPMSLIB/vspmslib.csh) then                            #VSPMS
    source $VSPMSLIB/vspmslib.csh                              #VSPMS
    set VSPMSPRT = `$VSPMSLIB/whatport`                        #VSPMS
    set path = ($path $VSPMSHOME/bin $VSPMSHOME/bin/$VSPMSPRT) #VSPMS
endif                                                          #VSPMS
if ($?prompt != 0) then                                        #VSPMS
    # MARK BASE ENVIRONMENT                                    #VSPMS
    pjresethome                                                #VSPMS
endif                                                          #VSPMS

END_CSHRC:
