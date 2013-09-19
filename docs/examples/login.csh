#set up terminal characteristics:
#echo IN LOGIN
#set verbose

stty intr '^C' erase '^H' kill '^U' susp '^Z'

alias tset /usr/ucb/tset
foreach dir ( /usr/ucb /usr/bin /bin /usr/local/bin )
    if ( -x $dir/tset ) then
        alias tset $dir/tset
        break
    endif
end

if ( -x `alias tset` ) then
    set noglob; eval `tset -s vt100`; unset noglob
    eval "`resize`"
    clear
else
    echo WARNING - tset command not found on this system
    setenv TERM vt100
endif

if !($?HOSTNAME) then
    setenv HOSTNAME `uname -n`
endif

set ignoreeof
set noclobber
set notify

set time = 1
date

pjresethome
setprompt
