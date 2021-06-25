#!/bin/bash

. auxiliar/common_functions.sh

function nis_client () {
    get_config_lines $3        # lines = [0: nis_server_name, 1: nis_server_ip]

    me=$(hostname -I | xargs)

    check_and_install_software $me $1 sshpass nis

    if [[ $me != $1 ]]
    then # remote
        sshpass -p "practicas" ssh -l practicas $1 "echo \"domain ${lines[0]} server ${lines[1]}\" >> /etc/yp.conf"
        sshpass -p "practicas" ssh -l practicas $1 "sed -ir 's/^(passwd|group|shadow|hosts).*$/& nis/g' /etc/nsswitch.conf"
        sshpass -p "practicas" ssh -l practicas $1 "echo \"session optional      pam_mkhomedir.so skel=/etc/skel umask=077\" >> /etc/pam.d/common-session"

        add_user_to_nis_server $me ${lines[1]}
        
        sshpass -p "practicas" ssh -l practicas $1 "read -p 'System needs to reboot to upload changes. Reboot now? [Y/n]' reboot_answer"

        sshpass -p "practicas" ssh -l practicas $1 "if [[ $reboot_answer == '' ]] || [[ ${^reboot_answer} == 'Y' ]]; then sudo reboot; else print_result 0 $0; fi"
    else # local
        echo "domain ${lines[0]} server ${lines[1]}" >> /etc/yp.conf
        sed -ir 's/^(passwd|group|shadow|hosts).*$/& nis/g' /etc/nsswitch.conf
        echo "session optional      pam_mkhomedir.so skel=/etc/skel umask=077" >> /etc/pam.d/common-session

        add_user_to_nis_server $me ${lines[1]}

        read -p "System needs to reboot to upload changes. Reboot now? [Y/n]" reboot_answer

        if [[ $reboot_answer == '' ]] || [[ ${^reboot_answer} == 'Y' ]]
        then
            sudo reboot
        else
            print_result 0 $0
        fi
    fi

}
function add_user_to_nis_server () {
    if [[ $1 != $2 ]]
    then # server remoto
        sshpass -p "practicas" ssh -l practicas $2 "cd /var/yp; make"
    else # server local
        cd /var/yp
        make
    fi
}
