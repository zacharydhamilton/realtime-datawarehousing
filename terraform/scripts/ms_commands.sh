#!/bin/sh

echo "Starting..." >> startup.log
echo "Updating yum..." >> startup.log
sudo yum update -y
echo "Updated yum." >> startup.log
echo "Installing docker..." >> startup.log
sudo yum install docker -y
echo "Docker installed." >> startup.log
echo "Starting docker service..." >> startup.log
sudo service docker start
echo "Docker service started." >> startup.log
echo "Starting mysql container..." >> startup.log
sudo docker run -p 3306:3306 --name mysql-server -d zachhamilton/rt-dwh-mysql >> startup.log
echo "Started mysql container in the background." >> startup.log
echo "Starting mysql readiness checks..." >> startup.log
seconds=1
MS_READY=1
while [ $MS_READY -ne 0 ]; do
    sudo docker exec mysql-server mysqladmin --user=debezium --password=rt-dwh-c0nflu3nt! ping | grep -q "mysqld is alive"
    MS_READY=$?
    echo "Mysql is unavailable, waiting for it...  $seconds seconds" >> startup.log
    sleep 1
    seconds=$(expr $seconds + 1)
done
echo "Completed mysql readniness checks." >> startup.log
echo "Starting mysql procedures..." >> startup.log
echo "Starting shuffle_customers()..." >> startup.log
sudo docker exec -d mysql-server mysql --user=debezium --password=rt-dwh-c0nflu3nt! -e 'call shuffle_customers();' customers
echo "Starting shuffle_demographics()..." >> startup.log
sudo docker exec -d mysql-server mysql --user=debezium --password=rt-dwh-c0nflu3nt! -e 'call shuffle_demographics();' customers
echo "Done..." >> startup.log