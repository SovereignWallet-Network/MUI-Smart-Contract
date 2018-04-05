This repository has the main contracts in SovereignWallet Network platform. The MUIToken contract is the main component in this repository. This repository is for testing purposes only, do not use it for real deployment.

# Testnet Deployment

---

We have a functional deployment running on ropsten testnet. The deployed contracts are as below.

1.  SovereignNetworkkcontract address = [0x3f549015d758ef30d355fc412f1386f753f9c0b0](https://ropsten.etherscan.io/address/0x3f549015d758ef30d355fc412f1386f753f9c0b0)

The abi of SovereignNetworkk contract is available at [link](https://github.com/phantomcoco/MUI_Solidity/blob/master/contracts/abi/MUIToken.abi)

## Functions

We describe the main functions of the MUIToken contract as below.

### setPrices

```
function setPrices(uint256 _newSellPrice,
                   uint256 _newBuyPrice) onlyOwner public {}
```

This function is called when set the current MUI's price in the admin tool.
This is the current price _`_newSellPrice`_ _`_newBuyPrice`_ applied when a user buys or sells in Sovereign Wallet Market.

### setBidPrice

```
function setBidPrice(uint256 _value) onlyOwner public {}
```

This function is called by the admin tool when set the current Bid MUI's price.
Set the price of the MUI Token's bid price when SovereignWallet Network need to buy the tokens.
_`_value`_ is applied when a user sells in Sovereign Wallet Market if bid supply is existed.

### setAvailableSupply

```
function setAvailableSupply(uint256 _value) onlyOwner public {}
```

This functions is called by the admin tool when set the limited amount of supply that the buyer can currently buy on SovereignWallet market. Buyer can't buy over _`_value`_ amount of tokens. The transaction will be failed.

### setBidSupply

```
function setBidSupply(uint256 _value) onlyOwner public {}
```

This function is called by the admin tool when set the limited amount of bid supply that buyer can currently sell on SovereignWallet market. Seller can't sell over _`_value`_ amount of tokens. The transaction will be failed.

### buy

```
function buy(address _buyer,
             uint256 _amount) public {}
```

This function is called when user buy the MUI tokens on SovereignWallet market.
Owner transfers the number of tokens proportional to the ether _`_amount`_ received to buyer's account.
The available supply is reduced by the amount of MUI tokens purchased by the buyer.

### sell

```
function sell(address _seller,
              uint256 _amount) public {}
```

This functions is called when user sell the MUI tokens on SovereignWallet market.
Owner send the amount of ehter proportional to the _`_amount`_ of tokens received to seller's account.

### send

```
function send(address _from,
              address _to,
              uint256 _amount) public {}
```

This functions is called when user send the MUI tokens to other user on SovereignWallet.
_`_from`_ is the source account who wants to transfer to _`_to`_ account.
The user can send to friend or set the destination address on our wallet application.
