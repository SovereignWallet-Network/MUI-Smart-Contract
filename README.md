This repository keeps the main contracts in SovereignWallet Network platform. 
The MUI token and Algorithmic Central Bank contracts are the main components in this repository.

# Testnet Deployment


The deployed contracts on the Ethereum mainnet are as follows.

1. MuiToken contract address = [0x35321c78a48dd9ace94c8e060a4fc279a3a2d9fc](https://etherscan.io/token/0x35321c78a48dd9ace94c8e060a4fc279a3a2d9fc)
2. Algorithmic Central Bank contract address = [0xd48165de9d697ae724e93a7fb2f44caa77610fa6](https://etherscan.io/address/0xd48165de9d697ae724e93a7fb2f44caa77610fa6)

## Algorithmic Central Bank Functions

The public functions of Algorithmic Central Bank are described as below.


### isPhaseActive
```
function isPhaseActive() public view returns (bool) {}
```

Returns true if the current phase is active, false otherwise.


### buyFromACB

```
function buyFromACB(uint256 _amount) public payable whenPhaseActive onlyWhiteListed
```

This function is called when the clien wants to buy the MUI tokens on SovereignWallet market.
The client is expected to transfer ether which is proportional to _`_amount`_ of token. Otherwise the transaction will be reverted. Ether cost should be calculated with the current sellPrice of ACB plus fee rate. The available supply is reduced by the amount of MUI tokens purchased.


### sellToACB

```
function sellToACB(uint256 _amount) public whenPhaseActive onlyWhiteListed
```

This functions is called when the client wants to sell the MUI tokens on SovereignWallet market.
The client is expected to have at least _`_amount`_ of balance of MUI tokens.


### feeCollector

```
function feeCollector(address to, uint256 fee) public payable
```

Transfers the recipient the ether sent alongside the transaction after fee deduction. _`to`_ is the address of the recipient and _`fee`_ is the fee to be applied to this transaction.


## Test

1. Install testing framework by running `npm i -g mocha chai chai-as-promised chai-bignumber`
2. Run `truffle test` in the project directory.
