const HDWalletProvider = require("truffle-hdwallet-provider");
const Deployer = require('./deployer.json');

module.exports = {
  networks: {
    // development: {
    //   host: "127.0.0.1",
    //   port: 9545,
    //   network_id: "*" // Match any network id
    // }
    "mainnet": {
      provider: () => new HDWalletProvider(Deployer.mnemonics.mainnet, Deployer.web3Providers.mainnet),
      network_id: 1,
      gas: 4700000
    },
    "ropsten-infura": {
      provider: () => new HDWalletProvider(Deployer.mnemonics.testnet, Deployer.web3Providers.ropsten),
      network_id: 3,
      gas: 4700000
    }
  }
};
