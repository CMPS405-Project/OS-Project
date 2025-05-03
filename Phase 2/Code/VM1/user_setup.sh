#!/bin/bash

assignGroup(){
    # Define users
    dev_lead="dev_lead1"
    ops_lead="ops_lead1"
    ops_monitor="ops_monitor1"

    # Assign dev_lead1
    sudo usermod -aG developers,dev_leads "$dev_lead"
    sudo usermod -aG sudo "$dev_lead"
    echo "$dev_lead is assigned to developers, dev_leads, and sudo groups"

    # Assign ops_lead1
    sudo usermod -aG operations,ops_admin "$ops_lead"
    sudo usermod -aG sudo "$ops_lead"
    echo "$ops_lead is assigned to operations, ops_admin, and sudo groups"

    # Assign ops_monitor1
    sudo usermod -aG operations,monitoring "$ops_monitor"
    echo "$ops_monitor is assigned to operations and monitoring groups"
}

assignGroup
