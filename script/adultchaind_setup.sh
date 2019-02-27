#!/bin/bash

# Setup
echo "Updating system..."
sudo apt-get update -y
sudo apt-get install -y apt-transport-https build-essential cron curl gcc git g++ make sudo vim wget
clear




# deps
apt-get update
apt-get upgrade -y
apt-get install wget tar nano unrar unzip libboost-all-dev libevent-dev software-properties-common -y
add-apt-repository ppa:bitcoin/bitcoin -y
apt-get update
apt-get install libdb4.8-dev libdb4.8++-dev -y

# Swap
fallocate -l 1500M /mnt/1500MB.swap
dd if=/dev/zero of=/mnt/1500MB.swap bs=1024 count=1572864
mkswap /mnt/1500MB.swap
swapon /mnt/1500MB.swap
chmod 600 /mnt/1500MB.swap
echo '/mnt/1500MB.swap  none  swap  sw 0  0' >> /etc/fstab

# Firewall
ufw allow 22/tcp
ufw limit 22/tcp
ufw allow 6969/tcp
ufw logging on
ufw --force enable

# Download latest node and install.
mkdir -p /tmp/adultchain
cd /tmp/adultchain
wget https://github.com/zoldur/AdultChain/releases/download/v1.2.2.0/adultchain.tar.gz
tar -xzf adultchain.tar.gz
sudo mv adultchain-cli /usr/local/bin
sudo mv adultchaind /usr/local/bin
cd
rm -rf /tmp/adultchain
mkdir ~/.adultchain

# Setup configuration for node.
rpcuser=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
rpcpassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')
cat >~/.adultchain/adultchain.conf <<EOL
rpcuser=$rpcuser
rpcpassword=$rpcpassword
daemon=1
txindex=1
EOL

# Start node.
adultchaind
