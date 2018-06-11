This repository has the main contracts in SovereignWallet Network platform. The MUI token contract and Algorithmic Central Bank contract are the main components in this repository. This repository is for testing purposes only, do not use it for real deployment.

# Testnet Deployment


We have a functional deployment running on ropsten testnet. The deployed contracts are as below.

1. MuiToken contract address = [...](https://ropsten.etherscan.io/address/...)
2. Algorithmic Central Bank contract address = [...](https://ropsten.etherscan.io/address/...)

## Algorithmic Central Bank Functions

The functions of Algorithmic Central Bank are described as below.

### setPrices

```
function setPrices(uint256 _newSellPrice,
                   uint256 _newBuyPrice) public onlyAdmin {}
```

This function can be called by admin to set the current MUI's price.
This is the current price _`_newSellPrice`_ _`_newBuyPrice`_ applied when a client wants to buy/sell tokens in Sovereign Wallet Market.


### setFeeRate

```
function setFeeRate(uint256 _newFeeRate) public onlyAdmin {}
```

This function can be called by admin to set service fee rate.


### setAvailableSupplies

```
function setAvailableSupplies(uint256 _newBuySupply,
                              uint256 _newSellSupply) public onlyAdmin {}
```

This functions can be called by admin to set the limited amount of supply that the buyer can currently buy/sell on SovereignWallet market. _`_newBuySupply`_ is the supply that ACB can buy tokens from clients up to that amount. And _`_newSellSupply`_ is the supply that ACB can sell tokens to clients up to that amount. Clients are not able to buy/sell more than the supplies.


### setPhasePeriod

```
function setPhasePeriod(uint256 startTime, 
                        uint256 endTime) public onlyAdmin {}
```

This function can be called by only admin to set start and end time of trading phase. _`startTime`_ & _`endTime`_ are unix epoch times.


### isPhaseActive
```
function isPhaseActive() public view returns (bool) {}
```

Returns true if the current phase is active, false otherwise.


### buyBack

```
function buyBack(uint256 _amount) public payable {}
```

This function is called by only admin in order to buy tokens from ACB.
The sender is expected to transfer ether which is proportional to _`_amount`_ of token. Otherwise the transaction will be reverted. Ether cost should be calculated with the current sellPrice of ACB plus fee rate. The available supply is reduced by the amount of MUI tokens purchased.


### buyFromACB

```
function buyFromACB(uint256 _amount) public payable whenPhaseActive onlyWhiteListed {}
```

This function is called when the clien wants to buy the MUI tokens on SovereignWallet market.
The client is expected to transfer ether which is proportional to _`_amount`_ of token. Otherwise the transaction will be reverted. Ether cost should be calculated with the current sellPrice of ACB plus fee rate. The available supply is reduced by the amount of MUI tokens purchased.


### sellToACB

```
function sellToACB(uint256 _amount) public whenPhaseActive onlyWhiteListed {}
```

This functions is called when the client wants to sell the MUI tokens on SovereignWallet market.
The client is expected to have at least _`_amount`_ of balance of MUI tokens.


## Test

1. Install testing framework by running `npm i -g mocha chai chai-as-promised chai-bignumber`
2. Run `truffle test` in the project directory.