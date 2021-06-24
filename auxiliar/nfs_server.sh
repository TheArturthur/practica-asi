#!/bin/bash

function nfs_server () {       # linearray[@] <client|server>
    get_config_lines $3 #lines = [0: exported_dir_1, 1: exported_dir_2, 2:exported_dir_3...]

    me=$(hostname -I | xargs)
    net_ip=$(sed -r 's/[0-9]+$/0/' <<< $me)

    check_and_install_software $me $1 sshpass nfs-kernel-server
    if [[ $me != $1 ]]
    then # remote
        sshpass -p "practicas" ssh -l practicas $1 "domain_name=$(domainname -b practicas-asi)"

        sshpass -p "practicas" ssh -l practicas $1 "sed -ir \"s/^# Domain.*$/Domain = $domain_name/\" /etc/idmapd.conf"

        for dir in $lines
        do
            sshpass -p "practicas" ssh -l practicas $1 "echo \"$dir $net_ip/24(rw,sync,fsid=0,no_root_squash,no_subtree_check)\" >> /etc/exports"
        done

        sshpass -p "practicas" ssh -l practicas $1 "/etc/init.d/nfs-kernel-server restart"
    else # local
        domain_name=$(domainname -b practicas-asi)

        sed -ir "s/^# Domain.*$/Domain = $domain_name/" /etc/idmapd.conf

        for dir in $lines
        do
            echo "$dir $net_ip/24(rw,sync,fsid=0,no_root_squash,no_subtree_check)" >> /etc/exports
        done

        /etc/init.d/nfs-kernel-server restart
    fi
}