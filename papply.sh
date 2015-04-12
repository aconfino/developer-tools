#!/bin/bash

TOOL=$1

if [ -z $TOOL ]; then
   echo "Please specify which tool you would like to run puppet against."
   echo "Example papply.sh bamboo"
   exit 1;
else
   sudo /usr/bin/puppet apply puppet-scripts/$TOOL/manifests/site.pp --modulepath=puppet-scripts/$TOOL/modules
fi
