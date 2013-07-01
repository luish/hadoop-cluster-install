#!/bin/bash

HADOOP_USER=hadoop
HADOOP_GROUP=hadoop
HADOOP_VERSION=1.1.2
HADOOP_FILENAME=hadoop-${HADOOP_VERSION}-bin.tar.gz
HADOOP_BASEDIR=/usr/local
HADOOP_DIR=${HADOOP_BASEDIR}/hadoop
HADOOP_DISTDIR=${HADOOP_BASEDIR}/hadoop-${HADOOP_VERSION}
HADOOP_MASTER_IP=192.168.1.128
HADOOP_MASTER_HOSTNAME=master

# Stop execution on error
set -e

# Install SSH, rsync and git
echo "Instalando SSH, rsync e git"
sudo apt-get install ssh rsync git

# Install Java
echo "Instalando Java"
sudo apt-get install openjdk-7-jdk

# Create Hadoop group
echo "Criando grupo ${HADOOP_GROUP}"
sudo addgroup hadoop

# Create Hadoop user
echo "Criando usuário ${HADOOP_USER}"
sudo adduser --home /home/${HADOOP_USER} --shell /bin/bash --gecos "Hadoop User" --ingroup hadoop hadoop

# Hadoop user password
#echo "Definindo senha para usuário hadoop"
#sudo passwd ${HADOOP_USER}

# SSH key
echo "Gerando chaves RSA pública e privada para o usuário ${HADOOP_USER}"
su -c 'ssh-keygen -t rsa -P ""' ${HADOOP_USER}

# SSH authorized keys
echo "Adicionando chave pública nas chaves autorizadas do SSH"
su -c 'cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys' ${HADOOP_USER}

# Create HDFS dir
echo "Criando HDFS e definindo permissões"
sudo mkdir -p /home/${HADOOP_USER}/tmp
sudo chmod 750 /home/${HADOOP_USER}/tmp
sudo chown ${HADOOP_USER}:${HADOOP_GROUP} /home/${HADOOP_USER}/tmp

# Extract Hadoop.tar.gz
echo "Extraindo arquivo hadoop-${HADOOP_VERSION}.tar.gz em ${DIR}"
sudo tar -zxf src/${HADOOP_FILENAME} -C ${HADOOP_BASEDIR}

# Symbolic link to Hadoop directory
echo "Criando link simbólico ${HADOOP_DIR} para o diretório ${HADOOP_DISTDIR}"
sudo ln -s ${HADOOP_DISTDIR} ${HADOOP_DIR}

# Copy config files
echo "Copiando arquivos de configuração"
sudo cp src/conf/*.xml ${HADOOP_DIR}/conf/
sudo cp src/conf/hadoop-env.sh ${HADOOP_DIR}/conf/

# Permissions on Hadoop directory
echo "Dando permissões ao diretório da instalação"
sudo chown -R ${HADOOP_USER}:${HADOOP_GROUP} ${HADOOP_DISTDIR} ${HADOOP_DIR}

# Format Namenode
echo "Formatando namenode"
su -c "${HADOOP_DIR}/bin/hadoop namenode -format" ${HADOOP_USER}

# Add Hadoop bin folder in $PATH
echo "Alterando o PATH e JAVA_HOME no .bashrc do usuário ${HADOOP_USER}"
su -c "echo 'export PATH=\$PATH:${HADOOP_DIR}/bin' >> ~/.bashrc" ${HADOOP_USER}

# Add master IP in hosts file
echo "Adicionando IP do servidor master no /etc/hosts"
echo -e "${HADOOP_MASTER_IP}\t${HADOOP_MASTER_HOSTNAME}" | sudo tee -a /etc/hosts > /dev/null

# Complete
echo "Installation Complete!"

