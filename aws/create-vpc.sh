#!/bin/bash

home_cidr=98.115.186.136/32

vpc_id=vpc-23426746
security_group_id=sg-35692c51

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
}

function getVpcState(){
   aws ec2 describe-vpcs --vpc-id $vpc_id --output text --query Vpcs[0].State
}

function createVpc(){
  vpc_id=$(aws ec2 create-vpc --cidr-block 10.0.0.0/16 --output text --query Vpc.VpcId)
  echo "Created vpc $vpc_id"
  checkState getVpcState "available"
  echo "VPC is available"
}

function enableDnsHostname(){
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

function getSubnetState(){
    aws ec2 describe-subnets --subnet-id $subnet_id --output text --query Subnets[0].State
}

function createDefaultSubnet(){
	subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.1.0/24 --output text --query Subnet.SubnetId)
	echo "Created default subnet $subnet_id"
	checkState getSubnetState "available"
	echo "Subnet is available"
}


#createVpc
#enableDnsHostname
#createSecurityGroup
#createDefaultSubnet