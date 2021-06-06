#!/bin/bash

. auxiliar/common_functions.sh

function mount () {     # linearray[@] -> $1: destination host; $2: service; $3: configuration file
    get_config_lines $3 #lines = [0: original_dir, 1: destination]
    
    # Get local IP address to configure in local or remote host:
    me=$(hostname -I | xargs)

    if [[ $me != $1 ]]
    then
        # Remote option:

        # Check if sshpass is installed. If not, install:
        sshpass -V > /dev/null

        if [[ $? -ne 0 ]]
        then
            echo "Installing required packages..."
            sudo apt-get update > /dev/null
            sudo apt-get install sshpass > /dev/null
            echo "All packages installed!"
        fi

        # Sequence of commands to create directories (if necessary) and mount the filesystem:
        MOUNT_LINE="echo practicas | sudo -S mkdir -p ${lines[@]}; echo practicas | sudo -S mount --bind ${lines[@]}"

        # Mount:
        sshpass -p "practicas" ssh -l practicas $1 ${MOUNT_LINE}

    else
        # Local option:
        echo practicas | sudo -S mkdir -p ${lines[@]}
        echo practicas | sudo -S sudo mount --bind ${lines[@]}

    fi    

    print_result $? $2
}
