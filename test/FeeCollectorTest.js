const BigNumber = web3.BigNumber;
require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .use(require('chai-string'))
    .should();

const Utils = require('./utils');
const FeeCollector = artifacts.require('FeeCollector');
const MuiToken = artifacts.require('MuiToken');


contract('FeeCollector', () => {
    const initTokenSupply = new BigNumber('15e6');
    const sentTokenAmount = new BigNumber('5e6');
    const sentEtherAmount = Utils.ether(1);
    const fixedFeeAmount = Utils.ether(0.1);
    const feePercentage = new BigNumber(5);
    const feePercentageDenominator = new BigNumber(100);
    const txCost = Utils.defaultTxCost();
    const admin = web3.eth.accounts[0];
    const beneficiary = web3.eth.accounts[1];
    const sender = web3.eth.accounts[2];
    const receiver = web3.eth.accounts[3];
    const nonAuthorizedAddr = web3.eth.accounts[4];
    const blacklistedAddr = web3.eth.accounts[5];

    beforeEach(async () => {
        // Deploy MUI Token contract
        this.token = await MuiToken.new(beneficiary);
        // Charge the user account with some MUI tokens
        this.token.transfer(sender, initTokenSupply, {from: beneficiary}).should.be.fulfilled;
        // Deploy FeeCollector contract and charge with some ether
        this.feeCollector = await FeeCollector.new(fixedFeeAmount, feePercentage, feePercentageDenominator, {value: Utils.ether(1)});
        // Charge FeeCollector contract with some MUI tokens
        this.token.transfer(this.feeCollector.address, initTokenSupply, {from: beneficiary}).should.be.fulfilled;
    });

    it('should reject direct ether receivals', async () => {
        await this.feeCollector.sendTransaction({value: Utils.ether(1)}).should.be.rejected; 
    });

    describe('Admin', () => {
        it('should be able to pause and unpause the contract', async () => {
            // First pause the contract
            await this.feeCollector.pause().should.be.fulfilled;
            // Then unpause it
            await this.feeCollector.unpause().should.be.fulfilled;
        });

        it('should be able to withdraw ether and token', async () => {
            let tokenAmount = new BigNumber(5000);
            let etherAmount = Utils.ether(1);

            let preAdminEtherBalance = await web3.eth.getBalance(admin);
            let preAdminTokenBalance = await this.token.balanceOf(admin);

            // Withdraw some ether from FeeCollector contrcat
            await this.feeCollector.withdrawEtherAuthorized(etherAmount, {from: admin}).should.be.fulfilled;
            // Withdraw some token from FeeCollector contrcat
            await this.feeCollector.withdrawTokenAuthorized(this.token.address, tokenAmount, {from: admin}).should.be.fulfilled;

            // Get the post balances to compare with pre balances
            let postAdminEtherBalance = await web3.eth.getBalance(admin);
            let postAdminTokenBalance = await this.token.balanceOf(admin);

            // Compare pre and post balances for both ether and token
            postAdminEtherBalance.should.be.bignumber.above(preAdminEtherBalance.add(etherAmount).sub(txCost));
            postAdminTokenBalance.should.be.bignumber.equal(preAdminTokenBalance.add(tokenAmount));
        });

        it('should be able to set fee and fee ratio', async () => {
            await this.feeCollector.setFee(fixedFeeAmount).should.be.fulfilled;
            await this.feeCollector.setFeeRatio(feePercentage, feePercentageDenominator).should.be.fulfilled;
        });

        it('should not be able to set fee ratio that its denominator is `0`', async () => {
            await this.feeCollector.setFeeRatio(feePercentage, 0).should.be.rejected;
        });

        it('should not be able to set fee ratio that its denominator greater than its dividend', async () => {
            let ratioDividend = new BigNumber(10);
            let ratioDenominator = new BigNumber(9);
            await this.feeCollector.setFeeRatio(ratioDividend, ratioDenominator).should.be.rejected;
        });
    });

    describe('Non-authorized callee', () => {
        it('should not be able to add/remove admin', async () => {
            // Try to add an address to blacklist as non-authorized callee
            await this.feeCollector.addAdmin(web3.eth.accounts[9], {from: nonAuthorizedAddr}).should.be.rejected;
            // Add an address to blacklist as admin
            await this.feeCollector.addAdmin(web3.eth.accounts[9]).should.be.fulfilled;
            // And then try to remove an address from blacklist as a non-authorized callee
            await this.feeCollector.removeAdmin(web3.eth.accounts[9], {from: nonAuthorizedAddr}).should.be.rejected;
        });

        it('should not be able to add/remove addresses to blacklist', async () => {
            // Try to add an address to blacklist as non-authorized callee
            await this.feeCollector.addToBlackList(web3.eth.accounts[9], {from: nonAuthorizedAddr}).should.be.rejected;
            // Add an address to blacklist as admin
            await this.feeCollector.addToBlackList(web3.eth.accounts[9]).should.be.fulfilled;
            // And then try to remove an address from blacklist as a non-authorized callee
            await this.feeCollector.addToBlackList(web3.eth.accounts[9], {from: nonAuthorizedAddr}).should.be.rejected;
        });

        it('should not be able to pause and unpause the contract', async () => {
            // Try to pause the contract
            await this.feeCollector.pause({from: nonAuthorizedAddr}).should.be.rejected;
            // First pause the contract as admin
            await this.feeCollector.pause().should.be.fulfilled
            // Then try unpause it as a non-authorized callee
            await this.feeCollector.unpause({from: nonAuthorizedAddr}).should.be.rejected;
        });

        it('should not be able to withdraw ether or token', async () => {
            let tokenAmount = new BigNumber(5000);
            // Try to withdraw some ether from Airdrop contrcat
            await this.feeCollector.withdrawEtherAuthorized(Utils.ether(1), {from: nonAuthorizedAddr}).should.be.rejected;
            // Try to withdraw some token from irdrop contrcat
            await this.feeCollector.withdrawTokenAuthorized(this.token.address, tokenAmount, {from: nonAuthorizedAddr}).should.be.rejected;
        });
    });

    describe('Fee collection', () => {
        let preSenderTokenBalance;
        let preSenderEtherBalance;
        let preReceiverTokenBalance;
        let preReceiverEtherBalance;
        let preContractTokenBalance;
        let preContractEtherBalance;

        let postSenderEtherBalance;
        let postSenderTokenBalance;
        let postReceiverEtherBalance;
        let postReceiverTokenBalance;
        let postContractEtherBalance;
        let postContractTokenBalance;

        beforeEach(async () => {
            // Get token&ether balances of the sender before any action
            preSenderTokenBalance = await this.token.balanceOf(sender);
            preSenderEtherBalance = await web3.eth.getBalance(sender);

            // Get token&ether balances of FeeCollector contract before any action
            preContractTokenBalance = await this.token.balanceOf(this.feeCollector.address);
            preContractEtherBalance = await web3.eth.getBalance(this.feeCollector.address);

            // Get token&ether balances of the receiver before any action
            preReceiverTokenBalance = await this.token.balanceOf(receiver);
            preReceiverEtherBalance = await web3.eth.getBalance(receiver);

            // Approve some allownce FeeCollector contract to transfer tokens on behalf of the sender
            await this.token.approve(this.feeCollector.address, initTokenSupply, {from: sender}).should.be.fulfilled;
        });

        describe('positive tests', () => {
            it('ether transfers charged by fixed amount of ether', async () => {
                // For ether transfers, pass token address as '0x0'.
                // `amount` parameter is ignored in ether transfers.
                // Therefore passing it as `0` will be just fine.
                await this.feeCollector.transferAndChargeByFee(
                    '0x0',
                    receiver,
                    '0',
                    {from: sender, value: sentEtherAmount.add(fixedFeeAmount)}
                ).should.be.fulfilled;
    
                // Get ether balance of the sender after the transfer
                postSenderEtherBalance = await web3.eth.getBalance(sender);
                // Get ether balance of the FeeCollector contract after the transfer
                postContractEtherBalance = await web3.eth.getBalance(this.feeCollector.address);
                // Get ether balance of the receiver after the transfer
                postReceiverEtherBalance = await web3.eth.getBalance(receiver);
    
                // Compare the pre&post ether balances for sender, receiver and the contract
                postSenderEtherBalance.should.be.bignumber.above(preSenderEtherBalance.sub(txCost).sub(fixedFeeAmount).sub(sentEtherAmount));
                postReceiverEtherBalance.should.be.bignumber.equal(preReceiverEtherBalance.add(sentEtherAmount));
                postContractEtherBalance.should.be.bignumber.equal(preContractEtherBalance.add(fixedFeeAmount));
            });
    
            it('ether transfers charged by percentage of transfer amount', async () => {
                let feeAmount = sentEtherAmount.mul(feePercentage).div(feePercentageDenominator);
                // For ether transfers, pass token address as '0x0'.
                // `amount` parameter is ignored in ether transfers.
                // Therefore passing it as `0` will be just fine.
                await this.feeCollector.transferAndChargeByFeeRatio(
                    '0x0',
                    receiver,
                    '0',
                    {from: sender, value: sentEtherAmount}
                ).should.be.fulfilled;
    
                // Get ether balance of the sender after the transfer
                postSenderEtherBalance = await web3.eth.getBalance(sender);
                // Get ether balance of the FeeCollector contract after the transfer
                postContractEtherBalance = await web3.eth.getBalance(this.feeCollector.address);
                // Get ether balance of the receiver after the transfer
                postReceiverEtherBalance = await web3.eth.getBalance(receiver);
    
                // Compare the pre&post ether balances for sender, receiver and the contract
                postSenderEtherBalance.should.be.bignumber.above(preSenderEtherBalance.sub(txCost).sub(sentEtherAmount));
                postReceiverEtherBalance.should.be.bignumber.equal(preReceiverEtherBalance.add(sentEtherAmount.sub(feeAmount)));
                postContractEtherBalance.should.be.bignumber.equal(preContractEtherBalance.add(feeAmount));
            });
    
            it('token transfers charged by fixed amount of ether', async () => {
                await this.feeCollector.transferAndChargeByFee(
                    this.token.address,
                    receiver,
                    sentTokenAmount,
                    {from: sender, value: fixedFeeAmount}
                ).should.be.fulfilled;
    
                // Get ether balance of the sender after the transfer
                postSenderEtherBalance = await web3.eth.getBalance(sender);
                // Get token balance of the sender after the transfer
                postSenderTokenBalance = await this.token.balanceOf(sender);
                // Get ether balance of the FeeCollector contract after the transfer
                postContractEtherBalance = await web3.eth.getBalance(this.feeCollector.address);
                // Get ether balance of the receiver after the transfer
                postReceiverTokenBalance = await this.token.balanceOf(receiver);
    
                // Compare the pre&post ether/token balances for sender, receiver and the contract
                postSenderEtherBalance.should.be.bignumber.above(preSenderEtherBalance.sub(txCost).sub(fixedFeeAmount));
                postSenderTokenBalance.should.be.bignumber.equal(preSenderTokenBalance.sub(sentTokenAmount));
                postReceiverTokenBalance.should.be.bignumber.equal(preReceiverTokenBalance.add(sentTokenAmount));
                postContractEtherBalance.should.be.bignumber.equal(preContractEtherBalance.add(fixedFeeAmount));
            });
    
            it('token transfers charged by percentage of transfer amount', async () => {
                let feeAmount = sentTokenAmount.mul(feePercentage).div(feePercentageDenominator);
                // For ether transfers, pass token address as '0x0'.
                // `amount` parameter is ignored in ether transfers.
                // Therefore passing it as `0` will be just fine.
                await this.feeCollector.transferAndChargeByFeeRatio(
                    this.token.address,
                    receiver,
                    sentTokenAmount,
                    {from: sender}
                ).should.be.fulfilled;
    
                // Get token balancesof the sender after the transfer
                postSenderTokenBalance = await this.token.balanceOf(sender);
                // Get token balance of the FeeCollector contract after the transfer
                postContractTokenBalance = await this.token.balanceOf(this.feeCollector.address);
                // Get token balance of the receiver after the transfer
                postReceiverTokenBalance = await this.token.balanceOf(receiver);
    
                // Compare the pre&post token balances for sender, receiver and the contract
                postSenderTokenBalance.should.be.bignumber.equal(preSenderTokenBalance.sub(sentTokenAmount));
                postReceiverTokenBalance.should.be.bignumber.equal(preReceiverTokenBalance.add(sentTokenAmount.sub(feeAmount)));
                postContractTokenBalance.should.be.bignumber.equal(preContractTokenBalance.add(feeAmount));
            });
        });

        describe('negative tests', () => {
            it('should reject 0x0 receiver address', async () => {
                // For ether transfers, pass token address as '0x0'.
                // `amount` parameter is ignored in ether transfers.
                // Therefore passing it as `0` will be just fine.
                await this.feeCollector.transferAndChargeByFee(
                    '0x0',
                    '0x0',
                    '0',
                    {from: sender, value: sentEtherAmount}
                ).should.be.rejected;
            });
    
            it('should reject if ether value of tx is less than fee amount', async () => {
                let feeAmount = fixedFeeAmount.sub(Utils.ether(0.001));
                // For ether transfers, pass token address as '0x0'.
                // `amount` parameter is ignored in ether transfers.
                // Therefore passing it as `0` will be just fine.
                await this.feeCollector.transferAndChargeByFee(
                    '0x0',
                    receiver,
                    '0',
                    {from: sender, value: feeAmount}
                ).should.be.rejected;
            });
    
            it('should reject if token address is 0x0', async () => {
                await this.feeCollector.transferAndChargeByFee(
                    '0x0',
                    receiver,
                    sentTokenAmount,
                    {from: sender}
                ).should.be.rejected;
            });
        });
    });

    describe('Blacklisted account', () => {
        beforeEach(async () => {
            await this.feeCollector.addToBlackList(blacklistedAddr).should.be.fulfilled;
        });

        it('should not able to transfer', async () => {
            // Ether transfers
            await this.feeCollector.transferAndChargeByFee(
                '0x0',
                receiver,
                '0',
                {from: blacklistedAddr, value: sentEtherAmount.add(fixedFeeAmount)}
            ).should.be.rejected;

            await this.feeCollector.transferAndChargeByFeeRatio(
                '0x0',
                receiver,
                '0',
                {from: blacklistedAddr, value: sentEtherAmount}
            ).should.be.rejected;

            // Token transfers
            await this.feeCollector.transferAndChargeByFee(
                this.token.address,
                receiver,
                sentTokenAmount,
                {from: blacklistedAddr, value: fixedFeeAmount}
            ).should.be.rejected;

            await this.feeCollector.transferAndChargeByFeeRatio(
                this.token.address,
                receiver,
                sentTokenAmount,
                {from: blacklistedAddr}
            ).should.be.rejected;
        });
    });
});
