#!/bin/bash

# REMOTE CONTROL:
# https://askubuntu.com/questions/1153764/shell-script-for-installing-the-software-from-local-machine-to-remote-machine

#
function get_config_lines {
    num_lines=( $(wc -l $1) )
    
    # Open file in new fd:
    exec 6<"$1"
    for ((i=0;i<${num_lines[0]};i++))
    do
        read line <&6
        lines[$i]="$line"
    done

    # Close file again:
    exec 6<&-
}

#
function print_result {
    if [[ $1 -ne 0 ]]
    then
        echo -e "\e[31m${2^}: Error while processing! \nRETURN CODE: $1\e[0m"
    else
        echo -e "\e[32m${2^} completed!\e[0m"
    fi
}

#
function check_and_install_software { # $1: $me, $2: objective, $3..$#: packages
    echo $@
    sudo apt-get update > /dev/null

    if [[ $1 == $2 ]] # local install
    then
        for package in "${@:3}"
        do
            dpkg -s $package > /dev/null 2>&1
            if [[ $? -ne 0 ]]
            then
                echo "Installing required package $package on $1..."
                sudo apt-get install $package
            fi
        done
    else # remote install
        check_if_host_is_known $2

        for package in "${@:3}"
        do
            if [[ $package == "sshpass" ]]
            then
                dpkg -s $package 
                echo "Installing sshpass locally..."
                sudo apt-get install $package
            else
                echo "Installing $package in $2..."
                sshpass -p "practicas" ssh -l practicas $2 "sudo apt-get install $package"
            fi
        done
    fi
    #echo -e "\e[32mAll packages installed!\e[0m"
}

#
function check_if_host_is_known () {
    IS_KNOWN=$(ssh-keygen -F $1)

    if ! [ -n "$IS_KNOWN" ]
    then
        ssh-keyscan $1 >> ~/.ssh/known_hosts
    fi
}