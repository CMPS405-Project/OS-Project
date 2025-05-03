#!/bin/bash

 setfacl -Rm g:developers:rwx /projects/development/source
 setfacl -Rm g:developers:r /projects/development/builds
 setfacl -Rm g:monitoring:r /var/operations/reports

echo "ACLs applied successfully."   