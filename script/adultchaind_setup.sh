#!/bin/bash
# Download latest node and install.
#adultchainlink=`curl -s https://api.github.com/repos/bulwark-crypto/bulwark/releases/latest | grep browser_download_url | grep linux64 | cut -d '"' -f 4`
mkdir -p /tmp/adultchain
cd /tmp/adultchain
#curl -Lo adultchain.tar.gz $adultchainlink
wget https://github.com/zoldur/AdultChain/releases/download/v1.2.2.0/adultchain.tar.gz
tar -xzf adultchain.tar.gz
sudo mv ./bin/* /usr/local/bin
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
