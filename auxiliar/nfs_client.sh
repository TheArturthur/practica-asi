#!/bin/bash

. ./auxiliar/common_functions.sh

function nfs_client () {       # linearray[@] <client|server>
    get_config_lines $3 #lines = [0: exported_dir_line_1, 1: exported_dir_line_2, 2:exported_dir_line_3...]

    me=$(hostname -I | xargs)
    net_ip=$(sed -r 's/[0-9]+$/0/' <<< $me)

    check_and_install_software $me $1 sshpass nfs-common mount

    if [[ $me != $1 ]]
    then # remote
        sshpass -p "practicas" ssh -l practicas $1 "domain_name=$(domainname -b practicas-asi)"

        sshpass -p "practicas" ssh -l practicas $1 "sed -ir \"s/^# Domain.*$/Domain = $domain_name/\" /etc/idmapd.conf"

        sshpass -p "practicas" ssh -l practicas $1 "/etc/init.d/nfs-common restart"
        
        range=${#lines[@]}
        for i in $(seq 0 $range)
        do
            sshpass -p "practicas" ssh -l practicas $1 "host=$(cut -f1 -d ' ' <<< ${lines[$i]})"
            sshpass -p "practicas" ssh -l practicas $1 "remote_dir=$(cut -f2 -d ' ' <<< ${lines[$i]})"
            sshpass -p "practicas" ssh -l practicas $1 "local_dir=$(cut -f3 -d ' ' <<< ${lines[$i]})"
            
            sshpass -p "practicas" ssh -l practicas $1 "mount -t nfs $host.$domain_name:$remote_dir $local_dir"

            sshpass -p "practicas" ssh -l practicas $1 "echo \"$host.$domain_name:$remote_dir    $local_dir    nfs    defaults    0    0\" >> /etc/fstab"
        done

    else # local
        domain_name=$(domainname -b practicas-asi)

        sed -ir "s/^# Domain.*$/Domain = $domain_name/" /etc/idmapd.conf

        /etc/init.d/nfs-common restart
        
        range=${#lines[@]}
        for i in $(seq 0 $range)
        do
            host=$(cut -f1 -d ' ' <<< ${lines[$i]})
            remote_dir=$(cut -f2 -d ' ' <<< ${lines[$i]})
            local_dir=$(cut -f3 -d ' ' <<< ${lines[$i]})
            
            mount -t nfs $host.$domain_name:$remote_dir $local_dir

            echo "$host.$domain_name:$remote_dir    $local_dir    nfs    defaults    0    0" >> /etc/fstab
        done
    fi
}