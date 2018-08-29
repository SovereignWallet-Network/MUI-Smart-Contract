const MuiToken = artifacts.require("./MuiToken.sol");
const ACB = artifacts.require("./PhaseBasedACB.sol");
const Airdrop = artifacts.require("./Airdrop.sol");

const initialSellPrice = 6 * 10 ** 9;       // 1 ether = 6000 MUI
// TODO: Change this number if you want to fund ACB contract with ether
const initialEtherDeposit = 10 * 10 ** 18;   // 10 ether

// Keep this for unit tests
module.exports = (deployer, network, accounts) => {
};

/*************MUI Token***************/
// Mainnet
// Mainnet deployment of MUI Token contract
// @see https://etherscan.io/token/0x35321c78a48dd9ace94c8e060a4fc279a3a2d9fc
// const MUI_TOKEN_ADDRESS = '0x35321c78a48dd9ace94c8e060a4fc279a3a2d9fc';

// Ropsten
// Testnet deployment of MUI Token contract
// @see https://ropsten.etherscan.io/token/0xb83acc3c4432c34855f5009d0ef944668790c445
// const MUI_TOKEN_ADDRESS = '0xb83acc3c4432c34855f5009d0ef944668790c445';

// Rinkeby
// Testnet deployment of MUI Token contract
// @see https://rinkeby.etherscan.io/token/0xb0225eaf243b9ca8eda582f0cad8ee175eddce9b
// const MUI_TOKEN_ADDRESS = '0xb0225eaf243b9ca8eda582f0cad8ee175eddce9b';

// Testnet Deployer
// module.exports = (deployer, network, accounts) => {
//     deployer.deploy(MuiToken, accounts[0])
//         .then( _ => console.log('Mui Token contract has been deployed successfully.'));
// };



/****************ACB*******************/
// Mainnet
// Mainnet deployment of ACB contract
// @see https://rinkeby.etherscan.io/address/0xD48165de9D697aE724e93A7FB2F44caa77610FA6
// const ACB_CONTRACT_ADDRESS = '0xD48165de9D697aE724e93A7FB2F44caa77610FA6';

// Ropsten
// Testnet deployment of ACB contract
// @see https://ropsten.etherscan.io/address/<0xA22bA337957750550f0A5A8d6C861eb36d82A2d8>
// const ACB_CONTRACT_ADDRESS = '0xA22bA337957750550f0A5A8d6C861eb36d82A2d8';

// Rinkeby
// Testnet deployment of ACB contract
// @see https://rinkeby.etherscan.io/address/0xa6e0f94b34d9fb40ff9824b70093ffba5209f32f
// const ACB_CONTRACT_ADDRESS = '0xa6e0f94b34d9fb40ff9824b70093ffba5209f32f';

// Testnet Deployer
// module.exports = (deployer, network, accounts) => {
//     deployer.deploy(ACB, MUI_TOKEN_ADDRESS, 0, initialSellPrice, {value: initialEtherDeposit})
//         .then( _ => console.log('ACB contract has been deployed successfully.'));
// };



/**************Airdrop*****************/
// Mainnet
// Mainnet deployment of Airdrop contract
// @see https://etherscan.io/address/<address>

// Ropsten
// Testnet deployment of Airdrop contract
// @see https://ropsten.etherscan.io/address/0x3f45618b2baf9852713e5435859891d7acb43f33

// Rinkeby
// Testnet deployment of Airdrop contract
// @see https://rinkeby.etherscan.io/address/0xc128f848df97eeb56dcc445cedf5686a8a7f4c46

// Testnet Deployer
// module.exports = (deployer, network, accounts) => {
//     deployer.deploy(Airdrop, MUI_TOKEN_ADDRESS, 6)
//         .then( _ => console.log('Airdrop contract has been deployed successfully.'));
// };



// Notice that in mainnet deployments, we set a delay before resolving the deployer.deploy() fucntion
// because, the transactions are not immediately available even if they are mined
// at that specific time. Therefore we need to wait a while until the tx is available.
// The delay period is not certain, set by trial!!!

// Mainnet deployer of Mui Token contract
// module.exports = (deployer, network, accounts) => {
//     deployer.deploy(MuiToken, accounts[0])
//         .then( _ => console.log('Mui Token contract has been deployed successfully.'));
// };

// Mainnet deployer of ACB contract
// module.exports = (deployer, network, accounts) => {
//     // Deploy ACB contract
//     deployer.deploy(ACB, MUI_TOKEN_ADDRESS, 0, initialSellPrice, {value: initialEtherDeposit})
//         .then(() => ACB.deployed())
//         .then(registry => new Promise(resolve => setTimeout(() => resolve(registry), 150000)))
//         .catch(e => console.log(`Deployer failed. ${e}`));
// };

// Mainnet deployer of Airdrop contract
// module.exports = (deployer, network, accounts) => {
//     // Deploy Airdrop contract
//     deployer.deploy(Airdrop, MUI_TOKEN_ADDRESS, 6)
//         .then(() => Airdrop.deployed())
//         .then(registry => new Promise(resolve => setTimeout(() => resolve(registry), 150000)))
//         .catch(e => console.log(`Deployer failed. ${e}`));
// };
