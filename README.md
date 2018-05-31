This repository has the main contracts in SovereignWallet Network platform. The MUIToken contract is the main component in this repository. This repository is for testing purposes only, do not use it for real deployment.

# Testnet Deployment

---

We have a functional deployment running on ropsten testnet. The deployed contracts are as below.

1.  SovereignNetworkkcontract address = [0x3f549015d758ef30d355fc412f1386f753f9c0b0](https://ropsten.etherscan.io/address/0x3f549015d758ef30d355fc412f1386f753f9c0b0)

The abi of SovereignNetworkk contract is available at [link](https://github.com/phantomcoco/MUI_Solidity/blob/master/contracts/abi/MUIToken.abi)

## Algorithmic Central Bank Functions

The functions of Algorithmic Central Bank are described as below.

### setPrices

```
function setPrices(uint256 _newSellPrice,
                   uint256 _newBuyPrice) onlyAdmin public {}
```

This function can be called by admin to set the current MUI's price.
This is the current price _`_newSellPrice`_ _`_newBuyPrice`_ applied when a client wants to buy/sell tokens in Sovereign Wallet Market.

### setFeeRate

```
function setFeeRate(uint256 _newFeeRate) onlyAdmin public {}
```
This function can be called by admin to set service fee rate.

### setAvailableSupplies

```
function setAvailableSupplies(uint256 _newBuySupply,
                              uint256 _newSellSupply) onlyAdmin public {}
```

This functions can be called by admin to set the limited amount of supply that the buyer can currently buy/sell on SovereignWallet market. _`_newBuySupply`_ is the supply that ACB can buy tokens from clients up to that amount. And _`_newSellSupply`_ is the supply that ACB can sell tokens to clients up to that amount. Clients are not able to buy/sell more than the supplies.

### buyFromACB

```
function buyFromACB(uint256 _amount) public payable {}
```

This function is called when the clien wants to buy the MUI tokens on SovereignWallet market.
The client is expected to transfer ether which is proportional to _`_amount`_ of token. Otherwise the transaction will be reverted. Ether cost should be calculated with the current sellPrice of ACB plus fee rate. The available supply is reduced by the amount of MUI tokens purchased by.

### sellToACB

```
function sellToACB(uint256 _amount) public {}
```

This functions is called when the client wants to sell the MUI tokens on SovereignWallet market.
The client is expected to have at least _`_amount`_ of balance of MUI tokens.
