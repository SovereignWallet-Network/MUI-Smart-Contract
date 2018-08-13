const BigNumber = web3.BigNumber;
require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(BigNumber))
    .use(require('chai-string'))
    .should();

const Utils = require('./utils');
const Airdropper = require('./airdropper');
const Airdrop = artifacts.require("Airdrop");
const MuiToken = artifacts.require("MuiToken");


contract('Airdrop', () => {
    let airdropSupply = new BigNumber(1000000);
    // Notice that this approximation does not neccessarily mean that it is correct.
    // Therefore do not rely on this approximation all the time
    // If there needs fine tuning to check/compare ether balances before and after transactions,
    // change this gas amount accordingly or adjust it by multiplying by some constants
    // Also it may change depending of gas fee!
    let approximateGasFee = new BigNumber('1e16'); // 0.01 ether
    let admin = web3.eth.accounts[0];
    let beneficiary = web3.eth.accounts[1];
    let nonAuthorizedAddr = web3.eth.accounts[3];
    let airdropBalances = createAirdropBalanceDB(web3.eth.accounts, 100);

    beforeEach(async () => {
        // Deploy MUI Token contract
        this.token = await MuiToken.new(beneficiary);
        // Deploy Airdrop contract
        this.airdrop = await Airdrop.new(this.token.address);
        // Fund the Airdrop contract with MUI token
        await this.token.transfer(this.airdrop.address, airdropSupply, {from: beneficiary});

        this.airdropper = new Airdropper(airdropBalances);
    });

    it('should reject direct ether receivals', async () => {
        await this.airdrop.sendTransaction({value: Utils.ether(1)}).should.be.rejected; 
    });

    it('should accept ether receivals through depositEther function', async () => {
        await this.airdrop.depositEther({value: Utils.ether(1)}).should.be.fulfilled; 
    });

    describe('Admin', () => {
        it('should be able to pause and unpause the contract', async () => {
            // First pause the contract
            await this.airdrop.pause().should.be.fulfilled;
            // Then unpause it
            await this.airdrop.unpause().should.be.fulfilled;
        });

        it('should be able to set incentives', async () => {
            let rootHashIncetives = this.airdropper.getRootHash();
            // First pause the contract
            await this.airdrop.pause().should.be.fulfilled;
            // Then set the incentives root hash
            await this.airdrop.setIncentives(rootHashIncetives).should.be.fulfilled;
            // Get the incetive root hash
            let expectedRootHashIncentives = await this.airdrop.incentiveRoothash();
            // Compare the expected value and the value set in advance
            expectedRootHashIncentives.should.equalIgnoreCase(rootHashIncetives);
        });

        it('should be able to withdraw ether and token', async () => {
            let tokenAmount = new BigNumber(5000);
            let etherAmount = Utils.ether(1);

            let preAdminEtherBalance = await web3.eth.getBalance(admin);
            let preAdminTokenBalance = await this.token.balanceOf(admin);
            
            // Send some ether to Airdrop contract first
            await this.airdrop.depositEther({value: etherAmount, from: beneficiary}).should.be.fulfilled; 
            // Withdraw some ether from Airdrop contrcat
            await this.airdrop.withdrawEtherAuthorized(etherAmount, {from: admin}).should.be.fulfilled;
            // Withdraw some token from Airdrop contrcat
            await this.airdrop.withdrawTokenAuthorized(this.token.address, tokenAmount, {from: admin}).should.be.fulfilled;

            // Get the post balances to compare with pre balances
            let postAdminEtherBalance = await web3.eth.getBalance(admin);
            let postAdminTokenBalance = await this.token.balanceOf(admin);

            // Compare pre and post balances for both ether and token
            postAdminEtherBalance.should.be.bignumber.above(preAdminEtherBalance.add(etherAmount).sub(approximateGasFee));
            postAdminTokenBalance.should.be.bignumber.equal(preAdminTokenBalance.add(tokenAmount));
        });
    });

    describe('Non-authorized callee', () => {
        it('should not be able to add/remove admin', async () => {
            // Try to add an address to blacklist as non-authorized callee
            await this.airdrop.addAdmin(web3.eth.accounts[9], {from: nonAuthorizedAddr}).should.be.rejected;

            // Add an address to blacklist as admin
            await this.airdrop.addAdmin(web3.eth.accounts[9]).should.be.fulfilled;
            // And then try to remove an address from blacklist as a non-authorized callee
            await this.airdrop.removeAdmin(web3.eth.accounts[9], {from: nonAuthorizedAddr}).should.be.rejected;
        });

        it('should not be able to add/remove addresses to blacklist', async () => {
            // Try to add an address to blacklist as non-authorized callee
            await this.airdrop.addToBlackList(web3.eth.accounts[9], {from: nonAuthorizedAddr}).should.be.rejected;

            // Add an address to blacklist as admin
            await this.airdrop.addToBlackList(web3.eth.accounts[9]).should.be.fulfilled;
            // And then try to remove an address from blacklist as a non-authorized callee
            await this.airdrop.addToBlackList(web3.eth.accounts[9], {from: nonAuthorizedAddr}).should.be.rejected;
        });

        it('should not be able to pause and unpause the contract', async () => {
            // Try to pause the contract
            await this.airdrop.pause({from: nonAuthorizedAddr}).should.be.rejected;

            // First pause the contract as admin
            await this.airdrop.pause().should.be.fulfilled
            // Then try unpause it as a non-authorized callee
            await this.airdrop.unpause({from: nonAuthorizedAddr}).should.be.rejected;
        });

        it('should not be able to set incentives', async () => {
            // First pause the contract as admin
            await this.airdrop.pause().should.be.fulfilled;
            // Try to set the root hash of incentives as a non-authorized callee (who is not admin)
            await this.airdrop.setIncentives(this.airdropper.getRootHash(), {from: nonAuthorizedAddr}).should.be.rejected;
        });

        it('should not be able to withdraw ether or token', async () => {
            let tokenAmount = new BigNumber(5000);

            // Try to withdraw some ether from Airdrop contrcat
            await this.airdrop.withdrawEtherAuthorized(Utils.ether(1), {from: nonAuthorizedAddr}).should.be.rejected;
            // Try to withdraw some token from irdrop contrcat
            await this.airdrop.withdrawTokenAuthorized(this.token.address, tokenAmount, {from: nonAuthorizedAddr}).should.be.rejected;
        });
    });

    describe('Airdropped account', () => {
        let index = 3;
        let claimer = web3.eth.accounts[index];
        let amount = new BigNumber(airdropBalances[claimer]);
        let preClaimerTokenBalance;
        let postClaimerTokenBalance;

        beforeEach(async () => {
            // First pause the contract as admin
            await this.airdrop.pause().should.be.fulfilled
            // Set the root hash of incentives
            await this.airdrop.setIncentives(this.airdropper.getRootHash()).should.be.fulfilled;
            // Get token balance of the claimer before any claim
            preClaimerTokenBalance = await this.token.balanceOf(claimer);
        });

        it('should be able to claim incentive', async () => {
            // Calculate merkle proof for the given claimer's address
            let merkleProof = this.airdropper.getMerkleProof(index);
            // Claim the incentive as a client
            await this.airdrop.claim(index, amount, merkleProof, {from: claimer}).should.be.fulfilled;
            // Incentive for the given address should be already claimed
            let isClaimed = await this.airdrop.isClaimed(index);
            isClaimed.should.be.true;
            // Check claimer token balance if it increases by amount of incetive claimed
            postClaimerTokenBalance = await this.token.balanceOf(claimer);
            postClaimerTokenBalance.should.be.bignumber.equal(preClaimerTokenBalance.add(amount));
        });

        it('should not be able to claim incentive when the contract is paused', async () => {
            // Pause the contract as admin
            await this.airdrop.pause().should.be.fulfilled;

            // Calculate merkle proof for the given claimer's address
            let merkleProof = this.airdropper.getMerkleProof(index);
            // Claim the incentive as a client
            await this.airdrop.claim(index, amount, merkleProof, {from: claimer}).should.be.rejected;
        });

        it('should not be able to claim incentive more than once', async () => {
            // Calculate merkle proof for the given claimer's address
            let merkleProof = this.airdropper.getMerkleProof(index);
            // Claim the incentive as a client
            await this.airdrop.claim(index, amount, merkleProof, {from: claimer}).should.be.fulfilled;
            // Try to claim again
            await this.airdrop.claim(index, amount, merkleProof, {from: claimer}).should.be.rejected;
        });

        it('should not be able to claim old incentives', async () => {
            let oldAmount = amount;
            // Calculate merkle proof for the given claimer's address
            let merkleProof = this.airdropper.getMerkleProof(index);
            // Claim the incentive
            await this.airdrop.claim(index, amount, merkleProof, {from: claimer}).should.be.fulfilled;

            // Calculate the root hash of new incentives
            let newAirdropBalances = createAirdropBalanceDB(web3.eth.accounts, 300);
            this.airdropper.updateRootHash(newAirdropBalances);

            // Update the root hash in Airdrop contract
            await this.airdrop.pause().should.be.fulfilled;
            await this.airdrop.setIncentives(this.airdropper.getRootHash()).should.be.fulfilled;
            
            // New incentive should be claimable
            let isClaimed = await this.airdrop.isClaimed(index);
            isClaimed.should.be.false;

            // Get the new incentive amount and the merkle proof for the given claimer's address
            amount = new BigNumber(newAirdropBalances[claimer]);
            merkleProof = this.airdropper.getMerkleProof(index);

            // Claim the incentive as a client
            await this.airdrop.claim(index, oldAmount, merkleProof, {from: claimer}).should.be.rejected;
        });
    });

    describe('Non-Airdropped account', () => {
        let index = 9;
        let claimer = web3.eth.accounts[index];
        let amount = new BigNumber(airdropBalances[claimer]);
        let nonAirdroppedAccount = '0x5aeda56215b167893e80b4fe645ba6d5bab767d0'; // Same address as accounts[9] but the last byte is different

        beforeEach(async () => {
            // Set the root hash of incentives
            await this.airdrop.pause().should.be.fulfilled;
            await this.airdrop.setIncentives(this.airdropper.getRootHash()).should.be.fulfilled;
        });

        it('should not be able to claim incentive', async () => {
            // Calculate merkle proof for the given claimer's address
            let merkleProof = this.airdropper.getMerkleProof(index);
            // Claim the incentive with the correct parameters as non-airdropped user
            await this.airdrop.claim(index, amount, merkleProof, {from: nonAirdroppedAccount}).should.be.rejected;
        });
    });

    describe('Blacklisted account', () => {
        let index = 9;
        let claimer = web3.eth.accounts[index];
        let amount = new BigNumber(airdropBalances[claimer]);

        beforeEach(async () => {
            // Set the root hash of incentives
            await this.airdrop.pause().should.be.fulfilled;
            await this.airdrop.setIncentives(this.airdropper.getRootHash()).should.be.fulfilled;

            // Blacklist the claimer
            await this.airdrop.addToBlackList(claimer).should.be.fulfilled;
        });

        it('should not be able to claim incentive', async () => {
            // Calculate merkle proof for the given claimer's address
            let merkleProof = this.airdropper.getMerkleProof(index);
            // Claim the incentive with the correct parameters as non-airdropped user
            await this.airdrop.claim(index, amount, merkleProof, {from: claimer}).should.be.rejected;
        });
    });
});

function createAirdropBalanceDB(accounts, multiplier) {
    let db = {};
    console.log('\n---------------------- AirDrop Addresses -----------------------');
    console.log('-Index\t\t\tAddress\t\t\t\tBalance');
    accounts.map((a, i) => {
        db[a] = (i * multiplier + 50).toString(); 
        console.log(`- ${i}\t${a}\t${db[a]}`);
    });
    console.log('----------------------------------------------------------------');
    return db;
}
