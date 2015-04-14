#!/bin/bash

function createInstance(){
  instance_id=$(aws ec2 run-instances --image-id ami-99bef1a9 --instance-type t2.micro --subnet-id subnet-92ce78e5 --key-name development --associate-public-ip-address --security-group-ids sg-d76362b2 --output text --query Instances[*].InstanceId)
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

function performInitialSCP(){
  scp -r -i development.pem -o stricthostkeychecking=no output.json ec2-user@$public_ip:~
}

createInstance
waitForRunningState
waitForIpAssignment
waitForStatusChecks
performInitialSCP












