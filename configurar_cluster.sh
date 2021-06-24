#!/bin/bash

# Las líneas en blanco serán ignoradas.
hashRegex="^[[:space:]]*$";
# Las líneas que comiencen por almohadilla (símbolo #) serán consideradas comentarios y, por tanto, ignoradas.
whiteRegex="^#.*";

# combine both regex in a big regex
filterRegex="$hashRegex|$whiteRegex"

lineFormatRegex="^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?) (raid|mount|lvm|(nis|nfs|backup)_(server|client)) (.+)"

function check_config_file () {
    counter=1

    while IFS= read -r line || [[ -n "$line" ]]
    do

        if [[ $line =~ $filterRegex ]]
        then
            ((counter++))
            continue
        fi
        if [[ ! $line =~ $lineFormatRegex ]]
        then
            echo "invalid format on line: $counter"
            return 1  
        fi
        if ! [[ $line =~ $filterRegex ]]
        then
            IFS=' ' read -ra line_array <<< "$line"
            case ${line_array[1]} in 
                "mount")
                    echo "Mounting in '${line_array[0]}' with configuration found in '${line_array[2]}...'"
                    . ./auxiliar/mount.sh
                    mount ${line_array[@]};;
                "raid")
                    echo "Configuring RAID in '${line_array[0]}' with configuration found in '${line_array[2]}...'"
                    . ./auxiliar/raid.sh
                    raid ${line_array[@]};;
                "lvm")
                    echo "Configuring LVM in '${line_array[0]}' with configuration found in '${line_array[2]}...'"
                    . ./auxiliar/lvm.sh
                    lvm ${line_array[@]};;
                "nis_server")
                    echo "Configuring NIS Server in '${line_array[0]}' with configuration found in '${line_array[2]}...'"
                    . ./auxiliar/nis.sh
                    nis_server ${line_array[@]};;
                "nis_client")
                    echo "Configuring NIS Client in '${line_array[0]}' with configuration found in '${line_array[2]}...'"
                    . ./auxiliar/nis.sh
                    nis_client ${line_array[@]};;
                "nfs_server")
                    echo "Configuring NFS Server in '${line_array[0]}' with configuration found in '${line_array[2]}...'"
                    . ./auxiliar/nfs_server.sh
                    nfs_server ${line_array[@]};;
                "nfs_client")
                    echo "Configuring NFS Client in '${line_array[0]}' with configuration found in '${line_array[2]}...'"
                    . ./auxiliar/nfs_client.sh
                    nfs_client ${line_array[@]};;
                "backup_server")
                    echo "Configuring Backup Server in '${line_array[0]}' with configuration found in '${line_array[2]}...'"
                    . ./auxiliar/backup_server.sh
                    backup_server ${line_array[@]};;
                "backup_client")
                    echo "Configuring Backup Client in '${line_array[0]}' with configuration found in '${line_array[2]}...'"
                    . ./auxiliar/backup_client.sh
                    backup_client ${line_array[@]};;
            esac
        fi
        ((counter++))
    done < "$1"
    unset IFS
    return 0
}

if [[ $# -ne 1 || $1 = "-h" || $1 = "--help" ]]
then
    echo "use: sudo $0 <configuration file>" >&2
    exit 1
fi

if ! [[ -f $1 ]]
then
    echo  "$0: $1: No such file exists" >&2
    exit 1
fi

if [ "$EUID" -ne 0 ]
then
    echo "Please run me as sudo/root!"
    exit 1
fi

# Call function to check the file syntax:
check_config_file $1

if [[ $? -ne 0 ]]
then
    echo "$0: $1: Wrong syntax. File stopped processing on line $counter." >&2
    exit 1
fi
