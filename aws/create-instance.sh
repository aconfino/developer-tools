#!/bin/bash

IMAGE_ID=ami-60a1e808
SUBNET=subnet-323da86b
SECURITY_GROUP=sg-64387f00
KEY_NAME=dev-poc-east

INSTANCE_TYPE=t2.micro
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

function getPublicIp(){
  public_ip=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query Reservations[0].Instances[0].PublicIpAddress) 
  echo "Public ip is $public_ip"
}

function tagInstance(){
   aws ec2 create-tags --resource $instance_id --tags Key=Name,Value=$TOOL Key=tool,Value=CD Key=stack,Value=DEV
}

function createInstance(){
  instance_id=$(aws ec2 run-instances --image-id $IMAGE_ID --instance-type $INSTANCE_TYPE --subnet-id $SUBNET --key-name $KEY_NAME --associate-public-ip-address --security-group-ids $SECURITY_GROUP --block-device-mappings "[{\"DeviceName\": \"/dev/sdh\",\"Ebs\":{\"VolumeSize\":30}}]" --output text --query Instances[*].InstanceId)
  echo "Created $instance_id"
  checkState getState "running" "$instance_id waiting for running state"
  echo "Instance $instance_id is running."
  checkState getInstanceStatus "ok" "$instance_id waiting for initialization"
  echo "Instance $instance_id has been initialized."  
}

function installGit(){
  echo "Installing git..."
  ssh -tt -i $PEM_FILE -o stricthostkeychecking=no ec2-user@$public_ip 'sudo yum -y install git'
}

function cloneRepo(){
  echo "Cloning repo,.."
  ssh -tt -i $PEM_FILE -o stricthostkeychecking=no ec2-user@$public_ip 'git clone http://github.com/aconfino/developer-tools/'
}

function bootstrap(){
  echo "Executing bootstrap...HERE WERE GO!!"
  ssh -tt -i $PEM_FILE -o stricthostkeychecking=no ec2-user@$public_ip "cp ~/developer-tools/bootstrap.sh ~/bootstrap.sh"
  ssh -tt -i $PEM_FILE -o stricthostkeychecking=no ec2-user@$public_ip "~/bootstrap.sh $TOOL"
}

function usage(){
  echo ""
  echo "Usage:"
  echo "create-instance.sh #1 #2 #3 #4"
  echo "#1 - tool to provision ()bamboo|jira|stash|nexus|sonar)"
  echo "#2 - AWS subnet id (optional)"
  echo "#3 - AWS security group id (optional)"
  echo "#4 - AWS key pair name (optional)"
  echo ""
}

function setup(){
    if [[ -z "$1" ]]
      then
        usage
	    exit 1;
    fi
	if [[ $2 != "" ]]
	  then
	    echo "Overriding SUBNET variable with command line argument $2"
		SUBNET=$2
	fi
	if [[ $3 != "" ]]
	  then
	    echo "Overriding SECURITY_GROUP variable with command line argument $3"
		SECURITY_GROUP=$3
	fi
	if [[ $4 != "" ]]
	  then
	    echo "Overriding KEY_NAME variable with command line argument $4"
		KEY_NAME=$4
	fi
	PEM_FILE=C:/projects/developer-tools/aws/$KEY_NAME.pem
}

setup $1 $2 $3 $4
createInstance
getPublicIp
tagInstance
installGit
cloneRepo
bootstrap