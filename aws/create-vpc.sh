#!/bin/bash

vpc_id=vpc-23426746
home_cidr=98.115.186.136/32

function createVpc(){
  vpc_id=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --output text --query Vpc.VpcId)
  echo "Created vpc $vpc_id"
}

function checkState(){
  current_state=$($1)
  counter=0
  
 while [ $current_state != $2 ]
    do
      sleep 5
      current_state=$($1)
	  ((counter=counter+5))
      echo "State is $current_stat...$counter secs"
  done
  echo "State is $current_state"
}

function getVpcState(){
   aws ec2 describe-vpcs --vpc-id $vpc_id --output text --query Vpcs[0].State
}

function enableDnsHostname(){
    echo $vpc_id
    checkState getVpcState "available"
	aws ec2 modify-vpc-attribute --vpc-id $vpc_id --enable-dns-hostnames
	echo "enabled dns hostnames for $vpc_id"

}

function createSecurityGroup(){
    security_group_id=$(aws ec2 create-security-group --group-name dev-poc --description "dev-poc only allows access from my IP address and machines in my subnet" --vpc-id $vpc_id --output text --query GroupId)
	echo "Created security group $security_group_id"
	aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 8000-9000 --source-group $security_group_id
	echo "Allowed instances within the same security group to communicate over ports 8000-9000"
	aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr $home_cidr
	echo "Allowed my ip to communicate over ssh to any instance in the group"
	aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 8000-9000 --cidr $home_cidr
	echo "Allowed my ip to communicate over ports 8000-9000 to any instance in the group"
}

#createVpc
#enableDnsHostname
createSecurityGroup