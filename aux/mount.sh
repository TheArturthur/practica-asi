#!/bin/bash

function get_config_lines {
    # open file in new fd
    exec 6<"$1"

    read line1 <&6
    read line2 <&6

    # close file again
    exec 6<&-
}

function mount () {     # linearray[@] -> $1 $2 $3
    get_config_lines $3
    echo "Mounting '$line1' in '$line2', according to file '$3'"

    # Check if sshpass is installed. If not, install:
    sshpass --version

    if [[ $? -ne 0 ]]
    then
        sudo apt update
        sudo apt install sshpass
    fi

    # Mount:
    sshpass -p 'practicas' ssh -t practicas@$1 sudo mount $line1 $line2
    
    if [[ $? -ne 0 ]]
    then
        echo -e "\e[31mError while mounting!\e[0m"
    else
        echo -e "\e[32mMount completed!\e[0m"
    fi
}
