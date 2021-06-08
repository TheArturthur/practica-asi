#!/bin/bash

# Opens the configuration file in use and extracts its lines into a variable.
# IN: PATH to config file
function get_config_lines {
    num_lines=( $(wc -l $1) )
    
    # Open file in new fd:
    exec 6<"$1"
    for (( i=0; i< $num_lines; i++ ))
    do
        read line <&6
        lines[$i]="$line"
    done

    # Close file again:
    exec 6<&-
}

# Prints whether the desired execution went as expected or not.
# IN: RET_CODE from the command executed
# IN: FUNCTION to be executed
function print_result {
    if [[ $1 -ne 0 ]]
    then
        echo -e "\e[31m${2^}: Error while processing! \nRETURN CODE: $1\e[0m"
    else
        echo -e "\e[32m${2^} completed!\e[0m"
    fi
}

# Lookup for the necessary software either locally or remotely, and installs it.
# IN: LOCAL IP
# IN: OBJECTIVE IP
# IN: PACKAGES to install
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
    
}

# Checks if remote host is known, and adds a ssh key if negative.
# IN: HOST
function check_if_host_is_known () {
    IS_KNOWN=$(ssh-keygen -F $1)

    if ! [ -n "$IS_KNOWN" ]
    then
        ssh-keyscan $1 >> ~/.ssh/known_hosts
    fi
}

# Splits names and sizes from LVM config file into its separate arrays.
# IN: LIST of ordered names & sizes
function get_lvm_names_and_sizes () {
    error_caught=0
    lv_names=""
    lv_sizes=""
    for lv_pair in ${lines[@]:2}
    do
        if [[ $lv_pair =~ ^[a-zA-Z]+$ ]]
        then
            lv_names="$lv_names $lv_pair"
        elif [[ $lv_pair =~ ^[0-9]+[A-Z]{2}$ ]]
        then
            lv_sizes="$lv_sizes $lv_pair"
        else
            echo -e "\e[31mERROR: Wrong word $lv_pair in config file!\e[0m"
            error_caught=1
        fi
    done

    if [ $error_caught -eq 1 ]
    then
        echo -e "\e[31mExecution stopped.\e[0m"
        exit 1
    fi
}