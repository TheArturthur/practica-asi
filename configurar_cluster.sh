#!/bin/bash

if [[ $# -ne 1 || $1 = "-h" || $1 = "--help" ]]
then
    echo "use: $0 <configuration file>" >&2
    exit 1
fi

if ! [[ -f $1 ]]
then
    echo  "$0: $1: No such file exists" >&2
    exit 1
fi

$file = $(sed -E -e 's/#.*//g' -e '/^[[:space:]]*$/d'  -e '/^$/d' $1) 

while read -r line || [[ -n "$line" ]]
do
    # COMMAND_on $line;
    if [[ $line =~ (^\s*'#'.*|^\s*$) ]] # obviar comentarioså
    then


    fi
    #[[ $(date) =~ ^Fri\ ...\ 13 ]] && echo "It's Friday the 13th!"
    # (^\s*#.*|^\s*$)

done < "$1"

exit 0