#!/bin/tcsh
# runinpj
# run a command in a pj

set p = `basename $0`
set USAGE = "Usage:  $p [-help] project command [command_args...]"

if ($#argv < 1) then
    echo "$USAGE"; exit 1
endif

if ("$1" == "-help" || "$1" == "-h") then
    shift
    echo "$USAGE"; exit 0
endif

if ($#argv < 1) then
    echo "$USAGE"; exit 1
endif

set project = "$1"
shift

if ($#argv < 1) then
    echo "$USAGE"; exit 1
endif

chpj $project
if ($status) then
    echo Failed to chpj $project
    exit 1
endif

#echo $PATH

eval $argv[*]

pjclean
