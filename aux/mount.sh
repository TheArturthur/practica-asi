#!/bin/bash

function get_config_lines {
    # Open file in new fd:
    exec 6<"$1"

    read line1 <&6
    read line2 <&6

    # Close file again:
    exec 6<&-
}

function mount () {     # linearray[@] -> $1: destination host; $2: service (not needed); $3: configuration file
    get_config_lines $3
    echo "Mounting '$line1' in '$line2', according to file '$3'"

    # Get local IP address to configure in local or remote host:
    me=$(hostname -I | xargs)

    if [[ $me != $1 ]]
    then
        # Remote option:

        # Check if sshpass is installed in remote. If not, install:
        sshpass -V

        if [[ $? -ne 0 ]]
        then
            sudo apt-get update
            sudo apt-get install sshpass
        fi

        # Sequence of commands to create directories (if necessary) and mount the filesystem:
        SCRIPT="echo practicas | sudo -S mkdir -p $line1 $line2; echo practicas | sudo -S mount --bind $line1 $line2"

        # Mount:
        sshpass -p "practicas" ssh -l practicas $1 ${SCRIPT}

    else
        # Local option:
        echo practicas | sudo -S mkdir -p $line1 $line2
        echo practicas | sudo -S sudo mount --bind $line1 $line2

    fi    

    returncode="$?"
    if [[ $returncode -ne 0 ]]
    then
        echo -e "\e[31mError while mounting! RET: $returncode\e[0m"
    else
        echo -e "\e[32mMount completed!\e[0m"
    fi
}
