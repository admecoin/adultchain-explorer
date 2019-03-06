
![Adultchain Logo](https://explorer.adultchain.me/img/largelogo.png)

Adultchain cryptocurrency block explorer.
_Forked from the bulwark explorer._


[![GitHub license](https://img.shields.io/github/license/bulwark-crypto/bulwark-explorer.svg)](https://github.com/bulwark-crypto/bulwark-explorer/blob/master/COPYING)
[![Build Status](https://travis-ci.org/Cryptokkie/adultchain-explorer.svg?branch=master)](https://travis-ci.org/Cryptokkie/adultchain-explorer) 





## Install
This installation procedure will install everything that is needed to run the AdultChain blockexplorer software.
 
Nginx, Mongodb, Nodejs, Yarn, the AdultChain daemon and CLI and the block explorer.
Firewall configuration, creation of swap disk, installation of cron jobs and configuration of the explorer client application. 

> This repo has only been tested on a Ubuntu 16.04 VPS
 
To start, run the following command from your Ubuntu server to clone the repository to a local folder:

```bash
git clone https://github.com/Cryptokkie/adultchain-explorer.git
```
The following command will execute the script that installs the packages and programs that are needed:
```sh 
bash script/install_adultchain.sh
```
When the script is done, navigate to the directory containg the files from the client application, and install the node packages:

```bash
cd /home/explorer/blockex
yarn install
```

#### SSL
To install a Let's encrypt certificate the instructions in the following guide were followed: https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-16-04
#### Configuration
Configuration should be good to go, but if you need to tweak something, edit the file `config.js`

#### Crontab
The following automated tasks are needed for BlockEx to update: 

- `yarn run cron:coin` - will fetch coin related information like price and supply from coinmarketcap.com.
- `yarn run cron:masternode` - updates the masternodes list in the database with the most recent information clearing old information before.
- `yarn run cron:peer` - gather the list of peers and fetch geographical IP information.
- `yarn run cron:block` - will sync blocks and transactions by storing them in the database.
- `yarn run cron:rich` - generate the rich list.

__Note:__ is is recommended to run all the crons before editing the crontab to have the information right away.  Follow the order above, start with `cron:coin` and end with `cron:rich`.

## Build (production)
At this time only the client web interface needs to be built using webpack. This can be done by running:
 ```bash
 yarn run build:web
 ```
This will bundle the application and put it in the `/public` folder for delivery.

## Run (development)
`yarn run start:api` - start the api.

`yarn run start:web` - start client, URL: [http://localhost:8081](http://localhost:8081).

## Test
`yarn run test:client` - run the client side tests.

`yarn run test:server` - test the rpc connection, database connection, and api endpoints.

## To-Do
- Write more tests
- Cluster support for api
