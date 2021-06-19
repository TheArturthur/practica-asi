#!/bin/bash

. ./auxiliar/common_functions.sh

function nis_server () {       # [destination_IP, "nis_server", conf_file]
    get_config_lines $3        # lines = [0: nis_server_name]

    me=$(hostname -I | xargs)
    net_ip=$(sed -r 's/[0-9]+$/0/' <<< $me)

    check_and_install_software $me $1 sshpass nis

    if [[ $me != $1 ]]
    then # remote

        sshpass -p "practicas" ssh -l practicas $2 "sudo sed -i \"s/NISSERVER=/NISSERVER=master/\" /etc/default/nis"
        sshpass -p "practicas" ssh -l practicas $2 "sudo sed -i -r \"s/^0.0.0.0/# 0.0.0.0/\" /etc/ypserv.securenets"
        sshpass -p "practicas" ssh -l practicas $2 "sudo echo \"255.255.255.0    $net_ip\" >> /etc/ypserv.securenets"
        sshpass -p "practicas" ssh -l practicas $2 "sudo sed -i \"s/MERGEPASSWD=false/MERGEPASSWD=true/\" /etc/default/nis"
        sshpass -p "practicas" ssh -l practicas $2 "sudo sed -i \"s/MERGEGROUP=false/MERGEGROUP=true/\" /etc/default/nis"
        sshpass -p "practicas" ssh -l practicas $2 "sudo echo \"$net_ip      $hostname.${lines[0]}      $hostname\" >> /etc/hosts"

        sshpass -p "practicas" ssh -l practicas $2 "sudo /usr/lib/yp/ypinit -m"

        sshpass -p "practicas" ssh -l practicas $2 "sudo service nis restart"

        # In case users where added:
        sshpass -p "practicas" ssh -l practicas $2 "sudo cd /var/yp ; make"

    else # local
        sed -i -r "s/^NISSERVER=.*$/NISSERVER=master/" /etc/default/nis
        sed -i -r "s/^0.0.0.0/# 0.0.0.0/" /etc/ypserv.securenets
        echo "255.255.255.0    $net_ip" >> /etc/ypserv.securenets
        sed -i -r "s/^ALL= /ALL= shadow /" /var/yp/Makefile.dpkg-new
        cp /var/yp/Makefile.dpkg-new /var/yp/Makefile
        echo "$net_ip      $hostname" >> /etc/hosts

        /usr/lib/yp/ypinit -m 
        
        service nis start

        # In case users where added:
        #cd /var/yp
        #make
    fi
}
