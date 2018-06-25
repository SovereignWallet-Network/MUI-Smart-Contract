const HDWalletProvider = require("truffle-hdwallet-provider");
const Deployer = require('./deployer.json');

module.exports = {
  networks: {
    "mainnet": {
      provider: () => new HDWalletProvider(Deployer.mnemonics.mainnet, Deployer.web3Providers.mainnet),
      network_id: 1,
      gas: 4700000
    },
    "ropsten": {
      provider: () => new HDWalletProvider(Deployer.mnemonics.testnet, Deployer.web3Providers.ropsten),
      network_id: 3,
      gas: 4700000
    },
    "rinkeby": {
      provider: () => new HDWalletProvider(Deployer.mnemonics.testnet, Deployer.web3Providers.rinkeby),
      network_id: 3,
      gas: 4700000
    }
  }
};
