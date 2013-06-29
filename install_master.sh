#!/bin/bash

HADOOP_USER=hadoop
HADOOP_BASEDIR=/usr/local
HADOOP_DIR=${HADOOP_BASEDIR}/hadoop

# Execute first the install_slave.sh
./install_slave.sh

# Remember to edit /etc/hosts with hostnames of slaves and their IPs
sudo nano /etc/hosts

# Copy masters and slaves conf files
sudo cp src/conf/{masters,slaves} ${HADOOP_DIR}/conf

# Copy public key to slaves
for SLAVE in $(cat src/conf/slaves)
do
    su -c "ssh-copy-id -i $HOME/.ssh/id_rsa.pub ${HADOOP_USER}@${SLAVE}" ${HADOOP_USER}
done
