#!/bin/bash

SUBNET_ID=$1
SECURITY_GROUP=$2

TIMESTAMP=$(date +%s)
LOGS=logs

if [ ! -d "$LOGS" ]; then
  mkdir -p $LOGS
fi

echo "Creating servers..."
create-instance.sh bamboo $SUBNET_ID $SECURITY_GROUP > $LOGS/create-bamboo-$TIMESTAMP.log &
create-instance.sh stash $SUBNET_ID $SECURITY_GROUP  > $LOGS/create-stash-$TIMESTAMP.log &
create-instance.sh jira $SUBNET_ID $SECURITY_GROUP  > $LOGS/create-jira-$TIMESTAMP.log &
create-instance.sh sonar $SUBNET_ID $SECURITY_GROUP  > $LOGS/create-sonar-$TIMESTAMP.log &
create-instance.sh nexus $SUBNET_ID $SECURITY_GROUP  > $LOGS/create-nexus-$TIMESTAMP.log &
echo "Please check the logs folder for details."