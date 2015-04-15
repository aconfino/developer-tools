#!/bin/bash

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

createVpc
enableDnsHostname