#!/bin/bash

IMAGE_ID=ami-60a1e808
SUBNET=subnet-19a28623
SECURITY_GROUP=sg-9dc580f9
KEY_NAME=dev-poc-east

INSTANCE_TYPE=t2.medium
PEM_FILE=$KEY_NAME.pem
TOOL=$1

function checkState(){
  current_state=$($1)
  counter=0
  
 while [ $current_state != $2 ]
    do
      sleep 5
      current_state=$($1)
	  ((counter=counter+5))
      echo "$3 $current_stat...$counter secs"
  done
}

function getState(){
  aws ec2 describe-instance-status --instance-ids $instance_id --output text --query InstanceStatuses[0].InstanceState.Name
}

function getInstanceStatus(){
  aws ec2 describe-instance-status --instance-ids $instance_id --output text --query InstanceStatuses[0].InstanceStatus.Status
}

function createInstance(){
  instance_id=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --subnet-id $SUBNET --key-name $KEY_NAME --associate-public-ip-address --security-group-ids $SECURITY_GROUP --block-device-mappings "[{\"DeviceName\": \"/dev/sdh\",\"Ebs\":{\"VolumeSize\":30}}]" --output text --query Instances[*].InstanceId)
  echo "Created $instance_id"
  checkState getState "running" "$instance_id waiting for running state"
  echo "Instance $instance_id is running."
  checkState getInstanceStatus "ok" "$instance_id waiting for initialization"
  echo "Instance $instance_id has been initialized."  
  public_ip=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query Reservations[0].Instances[0].PublicIpAddress) 
}

function installGit(){
  echo "Installing git..."
  ssh -t -i $PEM_FILE -o stricthostkeychecking=no ec2-user@$public_ip 'sudo yum -y install git'
}

function cloneRepo(){
  echo "Cloning repo,.."
  ssh -t -i $PEM_FILE -o stricthostkeychecking=no ec2-user@$public_ip 'git clone http://github.com/aconfino/developer-tools/'
}

function bootstrap(){
  echo "Executing bootstrap...HERE WERE GO!!"
  ssh -t -i $PEM_FILE -o stricthostkeychecking=no ec2-user@$public_ip "cp ~/developer-tools/bootstrap.sh ~/bootstrap.sh"
  ssh -t -i $PEM_FILE -o stricthostkeychecking=no ec2-user@$public_ip "~/bootstrap.sh $TOOL"
}

function verify(){
    if [[ -z $1 ]]
      then
        echo "Please specify a tool you wish to provision.  Example: create-instance.sh bamboo"
	    exit 1;
    fi
}

verify
createInstance
installGit
cloneRepo
bootstrap