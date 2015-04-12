#!/bin/bash

# This script is a bootstrap to run your puppet scripts
# Copy this script to your home directory
# It will clone to appropriate git repo every run

# The git repo contains puppet scripts to setup multiple servers
# Call the appropriate papply-foo.sh at the end to install the specific  server


BASE_DIR=/home/ec2-user
TOOLS_DIR=$BASE_DIR/developer-tools

function install_puppet {
  
  PUPPET_INSTALLED=$(rpm -qa | grep puppet)
  
  if [ ! PUPPET_INSTALLED ]; then
     echo "Installing Puppet"
     sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
     sudo yum -y install puppet
  else
     echo "Puppet is already installed"
  fi

}

function git_clone {
  cd $BASE_DIR
  rm -rf $TOOLS_DIR
  echo "Cleaned old scripts";
  echo "Cloning the repo...";
  git clone http://github.com/aconfino/developer-tools 
}

function papply {
  cd $TOOLS_DIR
  echo "pretending to papply something"
}

install_puppet
git_clone
papply


# Call the appropriate puppet script in papply


