const HDWalletProvider = require("truffle-hdwallet-provider");
const Deployer = require('./deployer.json');

module.exports = {
  networks: {
    "mainnet": {
      provider: () => new HDWalletProvider(Deployer.mnemonics.mainnet, Deployer.web3Providers.mainnet),
      network_id: 1,
      gas: 4700000,
      gasPrice: 100000000000  // 100 Gwei, Change this value according to price average of the deployment time
    },
    "ropsten": {
      provider: () => new HDWalletProvider(Deployer.mnemonics.testnet, Deployer.web3Providers.ropsten),
      network_id: 3,
      gas: 4700000,
      gasPrice: 50000000000  // 50 Gwei
    },
    "rinkeby": {
      provider: () => new HDWalletProvider(Deployer.mnemonics.testnet, Deployer.web3Providers.rinkeby),
      network_id: 4,
      gas: 4700000,
      gasPrice: 50000000000  // 50 Gwei
    },
    "kovan": {
      provider: () => new HDWalletProvider(Deployer.mnemonics.testnet, Deployer.web3Providers.kovan),
      network_id: 42,
      gas: 4700000,
      gasPrice: 50000000000  // 50 Gwei
    },
    "development": {
      host: "127.0.0.1",
      port: 7545,
      network_id: 5777,
    }
  },
  compilers: {
    solc: {
      version: "0.4.24"  // ex:  "0.4.20". (Default: Truffle's installed solc)
    }
 }
};
