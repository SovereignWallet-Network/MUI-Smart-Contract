const MuiToken = artifacts.require("./MuiToken.sol");
const ACB = artifacts.require("./PhaseBasedACB.sol");
const Airdrop = artifacts.require("./Airdrop.sol");

const initialSellPrice = 6 * 10 ** 9;       // 1 ether = 6000 MUI
const initialEtherDeposit = 5 * 10 ** 18;  // TODO: Change this in mainnet deployment
const TOKEN_ADDRESS = '0xb83acc3c4432c34855f5009d0ef944668790c445';

module.exports = (deployer, network, accounts) => {
    deployer.deploy(ACB, TOKEN_ADDRESS, 0, initialSellPrice, {value: initialEtherDeposit})
        .then( _ => console.log('ACB contract has been deployed successfully.'));
};

// module.exports = (deployer, network, accounts) => {
//     deployer.deploy(MuiToken, accounts[0]).then(async () => {
//         await deployer.deploy(ACB, MuiToken.address, 0, initialSellPrice, {value: initialEtherDeposit});
//         await deployer.deploy(Airdrop, MuiToken.address);
//     });
// };
