let Utils = require('./utils');

let BigNumber = web3.BigNumber;

let should = require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .should();

let MuiToken = artifacts.require("MuiToken");

contract('MUI Token', () => {
    let clientToken = new BigNumber(10000);
    // Notice that this approximation does not neccessarily mean that it is correct.
    // Therefore do not rely on this approximation all the time
    // If there needs fine tuning to check/compare ether balances before and after transactions,
    // change this gas amount accordingly or adjust it by multiplying by some constants
    // Also it may change depending of gas fee!
    let approximateGasFee = new BigNumber('2e16'); // 0.02 ether
    let owner = web3.eth.accounts[0];
    let beneficiary = web3.eth.accounts[1];
    let client = web3.eth.accounts[2];
    let nonAuthorizedAddr = web3.eth.accounts[3];


    beforeEach(async () => {
        // Deploy MUI Token contract
        this.token = await MuiToken.new(beneficiary);
    });

    it('should reject direct ether receivals', async () => {
        await this.token.sendTransaction({value: Utils.ether(1)}).should.be.rejected; 
    });

    describe('Owner', () => {
        it('should be able to pause and unpause the contract', async () => {
            // Check paused value
            let paused = await this.token.paused();
            paused.should.be.false;

            // Approve some amount of token for the owner in order to test `transferFrom()` later
            await this.token.approve(owner, clientToken, {from: beneficiary}).should.be.fulfilled;

            // Pause the contract
            await this.token.pause({from: owner}).should.be.fulfilled; 

            // Check paused value
            paused = await this.token.paused();
            paused.should.be.true;

            // Try to transfer token
            await this.token.transfer(client, clientToken, {from: beneficiary}).should.be.rejected;
            // Try to approve token
            await this.token.approve(owner, clientToken, {from: beneficiary}).should.be.rejected;
            // Try to transfer token from
            await this.token.transferFrom(beneficiary, client, clientToken, {from: owner}).should.be.rejected;

            // Unpause the contract
            await this.token.unpause({from: owner}).should.be.fulfilled; 

            // Check paused value
            paused = await this.token.paused();
            paused.should.be.false;

            // Transfer token
            await this.token.transfer(client, clientToken, {from: beneficiary}).should.be.fulfilled;
            // Approve token
            await this.token.approve(owner, clientToken, {from: beneficiary}).should.be.fulfilled;
            // Transfer token from
            await this.token.transferFrom(beneficiary, client, clientToken, {from: owner}).should.be.fulfilled;
        });

        it('should be able to transfer ownership', async () => {
            // Transfer ownership
            await this.token.transferOwnership(client, {from: owner}).should.be.fulfilled;
            // Try to claim ownership as a non authorized address
            await this.token.claimOwnership({from: nonAuthorizedAddr}).should.be.rejected;
            // Claim the ownership
            await this.token.claimOwnership({from: client}).should.be.fulfilled;

            // Try to execute owner funtionalities to double-check
            await this.token.pause({from: client}).should.be.fulfilled;
        });
    });

    describe('Non-authorized callee', () => {
        it('should not be able to call owner functions', async () => {
            await this.token.transferOwnership(client, {from: nonAuthorizedAddr}).should.be.rejected;
            await this.token.pause({from: nonAuthorizedAddr}).should.be.rejected;
        });
    });

});