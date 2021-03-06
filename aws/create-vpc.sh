#!/bin/bash

home_cidr=98.115.186.136/32
key_pair=dev-poc-east

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

function createInternetGateway(){
    echo "Creating internet gateway"
    internet_gateway_id=$(aws ec2 create-internet-gateway --output text --query InternetGateway.InternetGatewayId)
	echo "Attaching VPC $vpc_id to internet gateway $internet_gateway_id"
    aws ec2 attach-internet-gateway --vpc-id $vpc_id --internet-gateway-id $internet_gateway_id
}

function createSecurityGroup(){
    security_group_id=$(aws ec2 create-security-group --group-name dev-poc --description "dev-poc only allows access from my IP address and machines in my subnet" --vpc-id $vpc_id --output text --query GroupId)
	echo "Created security group $security_group_id"
	aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 7000-9000 --source-group $security_group_id
	echo "Allowed instances within the same security group to communicate over ports 8000-9000"
	aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 22 --cidr $home_cidr
	echo "Allowed my ip to communicate over ssh to any instance in the group"
	aws ec2 authorize-security-group-ingress --group-id $security_group_id --protocol tcp --port 7000-9000 --cidr $home_cidr
	echo "Allowed my ip to communicate over ports 8000-9000 to any instance in the group"
}

function getSubnetState(){
    aws ec2 describe-subnets --subnet-id $subnet_id --output text --query Subnets[0].State
}

function createDefaultSubnet(){
	subnet_id=$(aws ec2 create-subnet --vpc-id $vpc_id --cidr-block 10.0.1.0/24 --output text --query Subnet.SubnetId)
	echo "Created default subnet $subnet_id"
	checkState getSubnetState "available"
	echo "Modifying subnet to map public ips when launching instances"
	aws ec2 modify-subnet-attribute --subnet-id $subnet_id --map-public-ip-on-launch
	echo "Subnet is available"
}

function modifyRouteTable(){
     route_table_id=$(aws ec2 describe-route-tables --filter Name=vpc-id,Values=$vpc_id --output text --query RouteTables[0].RouteTableId)
	 route_id=$(aws ec2 create-route --route-table-id $route_table_id --gateway-id $internet_gateway_id --destination-cidr-block 0.0.0.0/0)
	 echo "Added internet gateway $internet_gateway_id to the main route table $route_table_id"
}

function removeOldKeyPair(){
    if [ -f $key_pair.pem ]; then
       echo "Deleting old pem $key_pair.pem"
	   rm -f $key_pair.pem
    fi
    existing_key_pair=$(aws ec2 describe-key-pairs --output text --query KeyPairs[0].KeyName)
	if [[ $existing_key_pair == $key_pair ]]; then
	   echo "Deleting key pair $key_pair from AWS"
	   aws ec2 delete-key-pair --key-name $key_pair
	fi
}

function createKeyPair(){
    echo "Creating key pair"
	aws ec2 create-key-pair --key-name $key_pair --output text --query KeyMaterial > $key_pair.pem
	chmod 400 $key_pair.pem
	echo "Generated $key_pair.pem"
}

function haveANiceDay(){
echo "==============================================="
echo "          VPC successfully created!            "
echo "VPC = $vpc_id"
echo "Internet Gateway = $internet_gateway_id"
echo "Subnet = $subnet_id"
echo "Security Group = $security_group_id"
echo "Key pair = $key_pair"
echo "                                               "
echo "             Have a nice day!                  "
echo "==============================================="
}

createVpc
enableDnsHostname
createInternetGateway
createSecurityGroup
createDefaultSubnet
modifyRouteTable
removeOldKeyPair
createKeyPair
haveANiceDay

./create-servers.sh $subnet_id $security_group_id

