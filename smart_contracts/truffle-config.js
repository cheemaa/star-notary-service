var HDWalletProvider = require('truffle-hdwallet-provider');

var mnemonic = 'sponsor note seek maximum review table menu mushroom payment sight relief puppy';

module.exports = {
  networks: {
    rinkeby: {
      provider: function() {
        return new HDWalletProvider(mnemonic, 'https://rinkeby.infura.io/v3/96d8bf0d62b44caca60e19ff8dbee980');
      },
      network_id: '3',
      gas: 4500000,
      gasPrice: 10000000000,
    },
    development: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "http://127.0.0.1:8545/");
      },
      network_id: '*',
    },
  }
};
