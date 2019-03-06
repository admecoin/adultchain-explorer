
/**

 * Global configuration object
 * When building the client application with yarn,
 * settings from a config.js file are used.
 *
 * !!!!!! The script/install_adultchain.sh creates and configures the config.js file automatically !!!!!!
 *
 *
 * To manually configure (not recommended):
 *
 * Create a config.js file by copying this file and name the copy config.js
 * From a commandline execute the following command:
 * cp config.template.js config.js
 *
 * Open config.js and edit the values you need to change.
 *
 */
const config = {
  'project': {
    'name': 'Name of your project',
    'tagline': 'Unicorns For The Masses',
    'ticker': 'UFTM'
  },
  'api': {
    'host': 'https://explorer.unicorns-and-poop-rainbows.com',
    'port': '443',
    'prefix': '/api',
    'timeout': '5s'
  },
  'coinMarketCap': {
    'api': 'http://api.coinmarketcap.com/v1/ticker/',
    'ticker': 'unicornformasses'
  },
  'db': {
    'host': '127.0.0.1',
    'port': '27017',
    'name': 'blockex',
    'user': 'blockexuser',
    'pass': 'Explorer!1'
  },
  'freegeoip': {
    'api': 'https://extreme-ip-lookup.com/json/'
  },
  'rpc': {
    'host': '127.0.0.1',
    'port': '52541',
    'user': 'bulwarkrpc',
    'pass': 'someverysafepassword',
    'timeout': 8000, // 8 seconds
  },
  'slack': {
    'url': 'https://hooks.slack.com/services/A00000000/B00000000/somekindofhashhere',
    //'channel': '#general',
    //'username': 'Block Report',
    //'icon_emoji': ':bwk:'
  }
};

module.exports = config;
