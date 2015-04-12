#!/bin/bash

TOOL=$1
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [ -z $TOOL ]; then
   echo "Please specify which tool you would like to run puppet against."
   echo "Example papply.sh bamboo"
   exit 1;
else
   sudo /usr/bin/puppet apply $DIR/puppet-scripts/$TOOL/manifests/site.pp --modulepath=$DIR/puppet-scripts/$TOOL/modules
fi
