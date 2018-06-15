const HDWalletProvider = require("truffle-hdwallet-provider");

const mnemonic = "distance sting mention other fragile vehicle bind immense reason force funny wolf";

module.exports = {
  networks: {
    // development: {
    //   host: "127.0.0.1",
    //   port: 9545,
    //   network_id: "*" // Match any network id
    // }
    // ropsten: {
    //   host: "127.0.0.1",
    //   port: 8545,
    //   network_id: 3,
    //   gas: 4700000
    // },
    "ropsten-infura": {
      provider: () => new HDWalletProvider(mnemonic, "https://ropsten.infura.io/zCPaFWlkAWiqVP0btZR1"),
      network_id: 3,
      gas: 4700000
    }
  }
};