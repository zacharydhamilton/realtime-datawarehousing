#!/bin/sh

echo "Starting..." >> startup.log
echo "Updating yum..." >> startup.log
sudo yum update -y
echo "Updated yum." >> startup.log
echo "--------------------------------------"
echo "Installing docker..." >> startup.log
sudo yum install docker -y
echo "Docker installed." >> startup.log
echo "--------------------------------------"
echo "Starting docker service..." >> startup.log
sudo service docker start
echo "Docker service started." >> startup.log
echo "--------------------------------------"
echo "Starting postgres container..." >> startup.log
sudo docker run -p 5432:5432 --name postgres -d zachhamilton/rt-dwh-postgres-products:2.0
echo "Started postgres container in the background." >> startup.log
echo "Done..." >> startup.log