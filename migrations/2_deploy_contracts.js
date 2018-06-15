const MuiToken = artifacts.require("./MuiToken.sol");
const ACB = artifacts.require("./PhaseBasedACB.sol");
const Airdrop = artifacts.require("./Airdrop.sol");

const initialPrice = 16 * 10 ** 13;
const startTime = Date.now() / 1000 + 60 * 5; // now + 5 minutes
const endTime = startTime + 60 * 60; // startTime + 1 hour
const initialEtherDeposit = 3 * 10 ** 18;  // TODO: Change this in mainnet deployment

console.log('startTime: ' + startTime);
console.log('endTime:   ' + endTime);


module.exports = (deployer, network, accounts) => {
    deployer.deploy(MuiToken, accounts[0]).then(async () => {
        await deployer.deploy(ACB, MuiToken.address, 0, initialPrice, startTime, endTime, {value: initialEtherDeposit});
        await deployer.deploy(Airdrop, MuiToken.address);
    });
};
