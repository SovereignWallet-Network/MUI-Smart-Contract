const MuiToken = artifacts.require('./MuiToken.sol');
const ACB = artifacts.require('./PhaseBasedACB.sol');
const Airdrop = artifacts.require('./Airdrop.sol');
const FeeCollector = artifacts.require('./FeeCollector.sol');

const initialSellPrice = 6 * 10 ** 9;       // 1 ether = 6000 MUI
// Change this number if you want to fund ACB contract with ether
const initialEtherDeposit = 10 * 10 ** 18;   // 10 ether

// Change these variables as needed
const fee = 10 ** 16        // 0.01 ether
const feeRatioDividend = 10
const feeRatioDenominator = 100


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
// @see https://etherscan.io/address/0x014ab4e86f5F46AE6F1CB83e5cC8aEB62a84604C

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


/**************FeeCollector*****************/
// Mainnet
// Mainnet deployment of FeeCollector contract
// @see https://etherscan.io/address/0xfbf17455eb6141b20572ca3c98cda244f1b57931

// Ropsten
// Testnet deployment of FeeCollector contract
// @see https://ropsten.etherscan.io/address/0xd5a21640fe441ad04c5a12648b0d71b4ed8e685b

// Rinkeby
// Testnet deployment of FeeCollector contract
// @see https://rinkeby.etherscan.io/address/0x185de914dc95f402c0cec883742e32476d8f609a

// Testnet Deployer
// module.exports = (deployer, network, accounts) => {
//     deployer.deploy(FeeCollector, fee, feeRatioDividend, feeRatioDenominator)
//         .then( _ => console.log('FeeCollector contract has been deployed successfully.'));
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

// Mainnet deployer of FeeCollector contract
// module.exports = (deployer, network, accounts) => {
//     // Deploy FeeCollector contract
//     deployer.deploy(FeeCollector, fee, feeRatioDividend, feeRatioDenominator)
//         .then(() => FeeCollector.deployed())
//         .then(registry => new Promise(resolve => setTimeout(() => resolve(registry), 150000)))
//         .catch(e => console.log(`Deployer failed. ${e}`));
// };

// For local testing only
    module.exports = (deployer, network, accounts) => {
        deployer.deploy(MuiToken, accounts[0])
            .then( _ =>{ 
                console.log('Mui Token contract has been deployed successfully.',MuiToken.address);
                deployer.deploy(ACB, MuiToken.address, 0, initialSellPrice, {value: initialEtherDeposit})
                        .then( _ => {
                            console.log('ACB contract has been deployed successfully.',ACB.address);
                            deployer.deploy(Airdrop, MuiToken.address, 6)
                                .then( _ => {
                                    console.log('Airdrop contract has been deployed successfully.',Airdrop.address);
                                    deployer.deploy(FeeCollector, fee, feeRatioDividend, feeRatioDenominator)
                                        .then( _ => console.log('FeeCollector contract has been deployed successfully.'))
                                        .catch(e => console.log(`FeeCollector Deployer failed. ${e}`));       
                                })
                                .catch(e => console.log(`Airdrop Deployer failed. ${e}`));  
                        })
                        .catch(e => console.log(`ACB Deployer failed. ${e}`));      
            })
            .catch(e => console.log(`MUI Deployer failed. ${e}`));
    };