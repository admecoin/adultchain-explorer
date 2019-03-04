#!/bin/bash
# https://raw.githubusercontent.com/Cryptokkie/bulwark-explorer/master/script/install_adultchain.sh
echo -e "${GREEN}Setting up variables...${NC}"
# Variables
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
EXPLORERFOLDER='/home/explorer'
DAEMONCONFIGFOLDER='/root/.adultchain'
adultchainfiles='https://github.com/zoldur/AdultChain/releases/download/v1.2.2.0/adultchain.tar.gz'
explorerrepolink='https://github.com/Cryptokkie/bulwark-explorer.git'
explorerip="104.238.136.162"
rpcuser=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')
rpcpassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')

echo "Adultchain files: $adultchainfiles"
echo "Explorer repository: $explorerrepolink"
echo "PWD: $PWD"
echo "EXPLORERFOLDER: $EXPLORERFOLDER"
echo "DAEMONCONFIGFOLDER: $DAEMONCONFIGFOLDER"
echo "User: $rpcuser"
echo "Pass: $rpcpassword"
sleep 5s
clear

installPackages () {
    # Setup
    echo -e "${GREEN}Updating system...${NC}"
    sudo apt-get update -y
    sudo apt-get install -y apt-transport-https build-essential cron curl gcc git g++ make sudo tar nano unrar unzip
    clear
}

prepareDaemonInstall () {
    # deps
    echo -e "${GREEN}Update and upgrade packages...${NC}"
    apt-get update
    apt-get upgrade -y
    apt-get install libboost-all-dev libevent-dev software-properties-common -y
    add-apt-repository ppa:bitcoin/bitcoin -y
    apt-get update
    apt-get install libdb4.8-dev libdb4.8++-dev -y

    # Error libminiupnpc missing...
    # @see https://github.com/virtauniquecoin/virtauniquecoin-master/issues/1
    # apt-cache search libminiupnpc
    apt-get install -y libminiupnpc10
    clear

    # Swap
    echo -e "${GREEN}Create swap...${NC}"
    fallocate -l 1500M /mnt/1500MB.swap
    dd if=/dev/zero of=/mnt/1500MB.swap bs=1024 count=1572864
    mkswap /mnt/1500MB.swap
    swapon /mnt/1500MB.swap
    chmod 600 /mnt/1500MB.swap
    echo '/mnt/1500MB.swap  none  swap  sw 0  0' >> /etc/fstab
    clear

    # Firewall
    echo -e "${GREEN}Setting up firewall ports...${NC}"
    ufw allow 22/tcp
    ufw allow 3000/tcp #explorer port
    # naahhh.... do the reverse proxy nginx thing so not: ufw allow 80/tcp // explorer port for production
    ufw limit 22/tcp
    ufw allow 6969/tcp #adultchain port
    ufw logging on
    ufw --force enable
    clear
}

installDaemon () {
    echo -e "${GREEN}Download adultchain daemon and install...${NC}"

    mkdir -p /tmp/adultchain
    cd /tmp/adultchain
    wget $adultchainfiles
    tar -xzf adultchain.tar.gz
    sudo mv adultchain-cli /usr/local/bin
    sudo mv adultchaind /usr/local/bin
    cd
    rm -rf /tmp/adultchain
    mkdir -p $DAEMONCONFIGFOLDER
    cat > $DAEMONCONFIGFOLDER/adultchain.conf << EOL
rpcport=52544
rpcuser=$rpcuser
rpcpassword=$rpcpassword
daemon=1
txindex=1
EOL
    sudo cat > /etc/systemd/system/adultchaind.service << EOL
[Unit]
Description=adultchaind
After=network.target
[Service]
Type=forking
User=explorer
WorkingDirectory=$DAEMONCONFIGFOLDER

ExecStart=/usr/local/bin/adultchaind -datadir=$DAEMONCONFIGFOLDER
ExecStop=/usr/local/bin/adultchain-cli -datadir=$DAEMONCONFIGFOLDER stop
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOL
    sudo systemctl start adultchaind
    sudo systemctl enable adultchaind
    echo "Sleeping for 1 hour while node syncs blockchain..."
    sleep 1h
    clear
}





installNodeAndYarn () {
    echo "Installing nodejs and yarn..."
    sudo curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
    sudo apt-get install -y nodejs npm
    sudo curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    sudo echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get update -y
    sudo apt-get install -y yarn
    sudo npm install -g pm2
    sudo ln -s /usr/bin/nodejs /usr/bin/node
    sudo chown -R explorer:explorer $EXPLORERFOLDER/.config
    clear
}

installNginx () {
    echo "Installing nginx..."
    sudo apt-get install -y nginx
    sudo rm -f /etc/nginx/sites-available/default
    sudo cat > /etc/nginx/sites-available/default << EOL
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html index.htm index.nginx-debian.html;
    #server_name explorer.bulwarkcrypto.com;
    server_name _;

    gzip on;
    gzip_static on;
    gzip_disable "msie6";

    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_min_length 256;
    gzip_types text/plain text/css application/json application/javascript application/x-javascript text/xml application/xml application/xml+rss text/javascript application/vnd.ms-fontobject application/x-font-ttf font/opentype image/svg+xml image/x-icon;

    location / {
        proxy_pass http://127.0.0.1:3000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_cache_bypass \$http_upgrade;
    }

    #listen [::]:443 ssl ipv6only=on; # managed by Certbot
    #listen 443 ssl; # managed by Certbot
    #ssl_certificate /etc/letsencrypt/live/explorer.bulwarkcrypto.com/fullchain.pem; # managed by Certbot
    #ssl_certificate_key /etc/letsencrypt/live/explorer.bulwarkcrypto.com/privkey.pem; # managed by Certbot
    #include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    #ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}

#server {
#    if ($host = explorer.bulwarkcrypto.com) {
#        return 301 https://\$host\$request_uri;
#    } # managed by Certbot
#
#	listen 80 default_server;
#	listen [::]:80 default_server;
#
#	server_name explorer.bulwarkcrypto.com;
#   return 404; # managed by Certbot
#}
EOL
    sudo systemctl start nginx
    sudo systemctl enable nginx
    clear
}

installMongo () {
    echo "Installing mongodb..."
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
    sudo echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
    sudo apt-get update -y
    sudo apt-get install -y --allow-unauthenticated mongodb-org
    sudo chown -R mongodb:mongodb /data/db
    sudo systemctl start mongod
    sudo systemctl enable mongod
    mongo blockex --eval "db.createUser( { user: \"$rpcuser\", pwd: \"$rpcpassword\", roles: [ \"readWrite\" ] } )"

    clear
}

installBulwark () {
    echo "Installing Bulwark..."
    mkdir -p /tmp/bulwark
    cd /tmp/bulwark
    curl -Lo bulwark.tar.gz $explorerrepolink
    tar -xzf bulwark.tar.gz
    sudo mv ./bin/* /usr/local/bin
    cd
    rm -rf /tmp/bulwark
    mkdir -p $EXPLORERFOLDER/.bulwark
    cat > $EXPLORERFOLDER/.bulwark/bulwark.conf << EOL
rpcport=52544
rpcuser=$rpcuser
rpcpassword=$rpcpassword
daemon=1
txindex=1
EOL
    sudo cat > /etc/systemd/system/bulwarkd.service << EOL
[Unit]
Description=bulwarkd
After=network.target
[Service]
Type=forking
User=explorer
WorkingDirectory=$EXPLORERFOLDER
ExecStart=$EXPLORERFOLDER/bin/bulwarkd -datadir=$EXPLORERFOLDER/.bulwark
ExecStop=$EXPLORERFOLDER/bin/bulwark-cli -datadir=$EXPLORERFOLDER/.bulwark stop
Restart=on-abort
[Install]
WantedBy=multi-user.target
EOL
    sudo systemctl start bulwarkd
    sudo systemctl enable bulwarkd
    echo "Sleeping for 1 hour while node syncs blockchain..."
    sleep 1h
    clear
}

installBlockEx () {
    echo "Installing BlockEx..."
    git clone $explorerrepolink $EXPLORERFOLDER/blockex
    cd $EXPLORERFOLDER/blockex
    yarn install
    cat > $EXPLORERFOLDER/blockex/config.js << EOL
const config = {
  'api': {
    'host': 'http://$explorerip',
    'port': '3000',
    'prefix': '/api',
    'timeout': '180s'
  },
  'coinMarketCap': {
    'api': 'http://api.coinmarketcap.com/v1/ticker/',
    'ticker': 'xxx'
  },
  'db': {
    'host': '127.0.0.1',
    'port': '27017',
    'name': 'blockex',
    'user': '$rpcuser',
    'pass': '$rpcpassword'
  },
  'freegeoip': {
    'api': 'https://extreme-ip-lookup.com/json/'
  },
  'rpc': {
    'host': '127.0.0.1',
    'port': '52544',
    'user': '$rpcuser',
    'pass': '$rpcpassword',
    'timeout': 12000, // 12 seconds
  }
};

module.exports = config;
EOL
    nodejs ./cron/block.js
    nodejs ./cron/coin.js
    nodejs ./cron/masternode.js
    nodejs ./cron/peer.js
    nodejs ./cron/rich.js
    clear
    cat > mycron << EOL
*/1 * * * * cd $EXPLORERFOLDER/blockex && ./script/cron_block.sh >> ./tmp/block.log 2>&1
*/1 * * * * cd $EXPLORERFOLDER/blockex && /usr/bin/nodejs ./cron/masternode.js >> ./tmp/masternode.log 2>&1
*/1 * * * * cd $EXPLORERFOLDER/blockex && /usr/bin/nodejs ./cron/peer.js >> ./tmp/peer.log 2>&1
*/1 * * * * cd $EXPLORERFOLDER/blockex && /usr/bin/nodejs ./cron/rich.js >> ./tmp/rich.log 2>&1
*/5 * * * * cd $EXPLORERFOLDER/blockex && /usr/bin/nodejs ./cron/coin.js >> ./tmp/coin.log 2>&1
EOL
    crontab mycron
    rm -f mycron
    pm2 start ./server/index.js
    sudo pm2 startup ubuntu
}



# Check for blockex folder, if found then update, else install.
if [ ! -d "$EXPLORERFOLDER/blockex" ]
then
    installPackages
    prepareDaemonInstall
    installDaemon
    installNginx
    installMongo
    #installBulwark
    installNodeAndYarn
    installBlockEx
    echo "Finished installation!"
else
    cd $EXPLORERFOLDER/blockex
    git pull
    pm2 restart index
    echo "BlockEx updated!"
fi

