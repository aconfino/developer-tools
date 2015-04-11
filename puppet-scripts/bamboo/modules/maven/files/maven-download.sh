#!/bin/bash

MAVEN_BASE_DIR=$1

echo "attempting download"
curl -o $MAVEN_BASE_DIR/apache-maven-3.2.5-bin.tar.gz http://mirror.nexcess.net/apache/maven/maven-3/3.2.5/binaries/apache-maven-3.2.5-bin.tar.gz
echo "successfully downloaded maven tarball"
tar -xvf $MAVEN_BASE_DIR/apache-maven-3.2.5-bin.tar.gz
echo "succesfully unpacked tarball"
