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

# Las líneas en blanco serán ignoradas.
hashRegex="^[[:space:]]*$";
# Las líneas que comiencen por almohadilla (símbolo #) serán consideradas comentarios y, por tanto, ignoradas.
whiteRegex="^#.*";

# combine both regex in a big regex
filterRegex="$hashRegex|$whiteRegex"


lineFormatRegex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?) (raid|mount|lvm|(nis|nfs|backup)_(server|client)) (.+)"
counter=1

while IFS= read -r line || [[ -n "$line" ]]
do
    if [[ $line =~ $filterRegex ]]
    then
        ((counter++))
        continue
    fi
    if [[ ! $line =~ $lineFormatRegex ]]
    then
        echo "invalid format on line: $counter"
        exit 1  
    fi
    ((counter++))
done < "$1"
exit 0