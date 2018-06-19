const MuiToken = artifacts.require("./MuiToken.sol");
const ACB = artifacts.require("./PhaseBasedACB.sol");
const Airdrop = artifacts.require("./Airdrop.sol");

const initialPrice = 16 * 10 ** 13;
const initialEtherDeposit = 3 * 10 ** 18;  // TODO: Change this in mainnet deployment


module.exports = (deployer, network, accounts) => {
    deployer.deploy(MuiToken, accounts[0]).then(async () => {
        await deployer.deploy(ACB, MuiToken.address, 0, initialPrice, {value: initialEtherDeposit});
        await deployer.deploy(Airdrop, MuiToken.address);
    });
};
