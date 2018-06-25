const MuiToken = artifacts.require("./MuiToken.sol");
const ACB = artifacts.require("./PhaseBasedACB.sol");
const Airdrop = artifacts.require("./Airdrop.sol");

const initialSellPrice = 6 * 10 ** 9;       // 1 ether = 6000 MUI
// TODO: Change this number if you want to fund ACB contract with ether
const initialEtherDeposit = 5 * 10 ** 18;   // 10 ether
// TODO: Do not use this address in mainnet deployment!!!!!
const TOKEN_ADDRESS = '0xb83acc3c4432c34855f5009d0ef944668790c445'; // MUIBT address, see https://ropsten.etherscan.io/token/0xb83acc3c4432c34855f5009d0ef944668790c445

// TODO: Comment out this function in mainnet deployment!!!!!!!
// module.exports = (deployer, network, accounts) => {
//     deployer.deploy(ACB, TOKEN_ADDRESS, 0, initialSellPrice, {value: initialEtherDeposit})
//         .then( _ => console.log('ACB contract has been deployed successfully.'));
// };

//TODO: Comment out this function in testnet deployment
// module.exports = (deployer, network, accounts) => {
//     // Deploy MuiToken contract
//     deployer.deploy(MuiToken, accounts[0]).then(() => {
//         // Deploy ACB contract
//         deployer.deploy(ACB, MuiToken.address, 0, initialSellPrice, {value: initialEtherDeposit});
//         // TODO: We will deploy Airdrop contract later separately!!!
//         //await deployer.deploy(Airdrop, MuiToken.address);
//     });
// };


module.exports = (deployer, network, accounts) => {
    // Deploy MuiToken contract
    deployer.deploy(MuiToken, accounts[0])
        .then(() => MuiToken.deployed())
        .then(registry => new Promise(resolve => setTimeout(() => resolve(registry), 150000)))
        .then(registry => {
            // Deploy ACB contract
            deployer.deploy(ACB, registry.address, 0, initialSellPrice, {value: initialEtherDeposit});
        })
        .catch(e => console.log(`Deployer failed. ${e}`));
};
