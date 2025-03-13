#!/bin/bash
    sudo setfacl -m g:developers:rwx /projects/development/source
    sudo setfacl -m g:developers:r /projects/development/builds
    sudo setfacl -m g:monitoring:r /var/operations/reports
