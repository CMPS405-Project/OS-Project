#!/bin/bash

assignGroup(){
    user=$1
    if [[ $user == dev_lead* ]]; then
        sudo usermod -aG developers,dev_leads "$user" 
        echo "$user is Assigned to developers and dev_leads group"
    elif [[ $user == ops_lead* ]]; then
        sudo usermod -aG operations,ops_admin "$user"
        echo "$user is Assigned to developers and ops_admin group"
 
    elif [[ $user == ops_monitor* ]]; then
        sudo usermod -aG operations,monitoring "$user" 
        echo "$user is Assigned to operations and monitoring group"
    fi
    if [[ $user == dev_lead1 ]]; then
        sudo usermod -aG sudo "$user" 
        echo "$user is Assigned to Sudoers group"
    fi
    if [[ $user == ops_lead1 ]]; then
    sudo usermod -aG sudo "$user" 
    echo "$user is Assigned to Sudoers group"
    fi
}
assignGroup "$1"