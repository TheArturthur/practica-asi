#!/bin/bash

. auxiliar/common_functions.sh

function lvm () {   
    get_config_lines $3 #lines = [0: group_name, 1: devices, 2:lv_1 name & size, 3:lv_2 name & size...]
    
    if [[ ${#lines} -lt 3 ]]
    then
        echo -e "\e[31m ERROR: Config file must have at least 3 lines!\n\e[0m"
        print_result $0 1
    fi

    me=$(hostname -I | xargs)

    check_and_install_software $me $1 sshpass pvcreate vgcreate lvcreate

    if [[ $me != $1 ]]
    then # remote
        sshpass -p "practicas" ssh -l practicas $1 "echo practicas | sudo -S pvcreate ${lines[1]}"
        sshpass -p "practicas" ssh -l practicas $1 "echo practicas | sudo -S vgcreate --name ${lines[0]} ${lines[1]}"

        get_lvm_names_and_sizes ${lines[@]:2}
        range=${#lv_names[@]}
        for i in $(seq 0 $range)
        do
            sshpass -p "practicas" ssh -l practicas $1 "echo practicas | sudo -S lvcreate --name ${lv_names[$i]} --size ${lv_sizes[$i]} ${lines[0]}"
        done

    else # local
        pvcreate ${lines[1]}
        vgcreate --name ${lines[0]} ${lines[1]}

        get_lvm_names_and_sizes ${lines[@]:2}
        range=${#lv_names[@]}
        for i in $(seq 0 $range)
        do
            lvcreate --name ${lv_names[$i]} --size ${lv_sizes[$i]} ${lines[0]}
        done
    fi
}
