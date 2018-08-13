const MuiToken = artifacts.require("./MuiToken.sol");
const ACB = artifacts.require("./PhaseBasedACB.sol");
const Airdrop = artifacts.require("./Airdrop.sol");

const initialSellPrice = 6 * 10 ** 9;       // 1 ether = 6000 MUI
// TODO: Change this number if you want to fund ACB contract with ether
const initialEtherDeposit = 10 * 10 ** 18;   // 10 ether


// Do not use this address in mainnet deployment!!!!!
// MUIBT address, @see https://ropsten.etherscan.io/token/0xb83acc3c4432c34855f5009d0ef944668790c445
const MUIBT_TOKEN_ADDRESS = '0xb83acc3c4432c34855f5009d0ef944668790c445';

// MUI token contract address on mainnet
// @see https://etherscan.io/token/0x35321c78a48dd9ace94c8e060a4fc279a3a2d9fc
const MUI_TOKEN_ADDRESS = '0x35321c78a48dd9ace94c8e060a4fc279a3a2d9fc'; 


// Local test deployment of MUI token and ACB contracts
module.exports = (deployer, network, accounts) => {
};

// Testnet deployment of MUI token and ACB contracts
/*module.exports = (deployer, network, accounts) => {
    deployer.deploy(ACB, MUIBT_TOKEN_ADDRESS, 0, initialSellPrice, {value: initialEtherDeposit})
        .then( _ => console.log('ACB contract has been deployed successfully.'));
};*/

// Testnet deployment of Airdrop contract
// module.exports = (deployer, network, accounts) => {
//     deployer.deploy(Airdrop, MUIBT_TOKEN_ADDRESS)
//         .then( _ => console.log('Airdrop contract has been deployed successfully.'));
// };



// Notice that in mainnet deployments we set a delay before resolving the deployer.deploy() fucntion
// because, the transactions are not immediately available even if they are mined
// at that specific time. Therefore we need to wait a while until the tx is available.
// The delay period is not certain, set by trial!!!

// Mainnet deployment of ACB contract
/*module.exports = (deployer, network, accounts) => {
    // Deploy ACB contract
    deployer.deploy(ACB, MUI_TOKEN_ADDRESS, 0, initialSellPrice, {value: initialEtherDeposit})
        .then(() => ACB.deployed())
        .then(registry => new Promise(resolve => setTimeout(() => resolve(registry), 150000)))
        .catch(e => console.log(`Deployer failed. ${e}`));
};*/

// Mainnet deployment of Airdrop contract
/*module.exports = (deployer, network, accounts) => {
    // Deploy Airdrop contract
    deployer.deploy(Airdrop, MUI_TOKEN_ADDRESS)
        .then(() => Airdrop.deployed())
        .then(registry => new Promise(resolve => setTimeout(() => resolve(registry), 150000)))
        .catch(e => console.log(`Deployer failed. ${e}`));
};*/
