#!/bin/bash

IMAGE_ID=ami-99bef1a9
INSTANCE_TYPE=t2.medium
SUBNET=subnet-92ce78e5
KEY_NAME=development
SECURITY_GROUP=sg-d76362b2
PEM_FILE=c:\projects\aws-work\development.pem
TOOL=$1

function createInstance(){
  instance_id=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --subnet-id $SUBNET --key-name $KEY_NAME --associate-public-ip-address --security-group-ids $SECURITY_GROUP --block-device-mappings "[{\"DeviceName\": \"/dev/sdh\",\"Ebs\":{\"VolumeSize\":30}}]" --output text --query Instances[*].InstanceId)
  echo "Created $instance_id"
}

function checkState(){
  instance_state=$(aws ec2 describe-instance-status --instance-ids $instance_id --output text --query InstanceStatuses[0].InstanceState.Name)
}

function waitForRunningState(){
  echo "Waiting for state"
  checkState
  while [ $instance_state != "running" ]
    do
      sleep 5
      checkState
      echo "State is $instance_state"
  done
  echo "State is $instance_state"
}

function checkPublicIp(){
  public_ip=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query Reservations[0].Instances[0].PublicIpAddress)
}

function waitForIpAssignment(){
  echo "Waiting for ip assignment"
  checkPublicIp
  while [ $public_ip == "None" ]
    do
      sleep 5
      checkPublicIp
      echo "Public ip is $public_ip"
  done
  echo "Public ip is $public_ip"
}

function checkStatus(){
  status=$(aws ec2 describe-instance-status --instance-ids $instance_id --output text --query InstanceStatuses[0].InstanceStatus.Status)
}

function waitForStatusChecks(){
  echo "Waiting for status check"
  checkStatus
  while [ $status != "ok" ]
    do
      sleep 5
      checkStatus
      echo "Status is $status"	  
  done
  echo "Status is $status"
}

function installGit(){
  ssh -t -i $PEM_FILE -o stricthostkeychecking=no ec2-user@$public_ip 'sudo yum -y install git'
}

function cloneRepo(){
  ssh -t -i $PEM_FILE -o stricthostkeychecking=no ec2-user@$public_ip 'git clone http://github.com/aconfino/developer-tools/'
}

function bootstrap(){
  ssh -t -i $PEM_FILE -o stricthostkeychecking=no ec2-user@$public_ip 'cp /developer-tools/boostrap.sh ~/boostrap.sh'
  ssh -t -i $PEM_FILE -o stricthostkeychecking=no ec2-user@$public_ip 'boostrap.sh $TOOL'
}

if [ -z "$1" ]
  then
    echo "Please specify a tool you wish to provision.  Example: create-instance.sh bamboo"
	exit 1;
fi

createInstance
waitForRunningState
waitForIpAssignment
waitForStatusChecks
installGit
cloneRepo
bootstrap