#!/bin/bash

. auxiliar/common_functions.sh

function lvm () {       
    get_config_lines $2 #lines = [0: group_name, 1: devices, 2:lv_1 name & size, 3:lv_2 name & size...]

    
}
