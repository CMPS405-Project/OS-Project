#!/bin/bash

assignGroup(){
    user=$1
    if [[ $user == dev_lead* ]]; then
        sudo usermod -aG developers,dev_leads "$user" 
    elif [[ $user == ops_lead* ]]; then
        sudo usermod -aG developers,ops_admin "$user" 
    elif [[ $user == ops_monitor* ]]; then
        sudo usermod -aG operations,monitoring "$user" 


    fi
}
assignGroup "$1"