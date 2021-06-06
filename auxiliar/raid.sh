#!/bin/bash

. auxiliar/common_functions.sh

function raid () {
    get_config_lines $3 #lines = [0: raid_device, 1: mode, 2: component-devices]

    devices=( ( "${lines[2]}" ) )
    devices_array=( $devices )

    echo ${devices[0]}

    exit 1
    # Get local IP address to configure in local or remote host:
    me=$(hostname -I | xargs)
   
    check_and_install_software $me $1 sshpass mdadm
    if [[ $me != $1 ]]
    then
        # Sequence of commands to create directories (if necessary) and mount the filesystem:

        RAID_LINE="echo practicas | sudo -S mdadm --create ${lines[0]} --level=${lines[1]} --raid-devices=${#devices_array[@]} ${lines[2]}"

	    sshpass -p "practicas" ssh -l practicas $1 ${RAID_LINE}
    else
        # Local option:
        echo practicas | sudo -S mdadm --create ${lines[0]} --level=${lines[1]} --raid-devices=${#devices_array[@]} ${lines[2]}
    fi

    print_result $? $2
}
