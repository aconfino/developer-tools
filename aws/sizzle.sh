#!/bin/bash

TIMESTAMP=$(date +%s)
LOGS=logs

if [ ! -d "$LOGS" ]; then
  mkdir -p $LOGS
fi

create-instance.sh bamboo > $LOGS/create-bamboo-$TIMESTAMP.log &
create-instance.sh stash > $LOGS/create-stash-$TIMESTAMP.log &
create-instance.sh jira > $LOGS/create-jira-$TIMESTAMP.log &
create-instance.sh sonar > $LOGS/create-sonar-$TIMESTAMP.log &