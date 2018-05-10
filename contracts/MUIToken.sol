pragma solidity 0.4.19;


import "./SafeMath.sol";
import "./EIP20Interface.sol";
import "./EIP20.sol";
import "./PermissionGroups.sol";
import "./Owned.sol";
import "./Withdrawable.sol";

contract MuiToken is Owned, EIP20, PermissionGroups, Withdrawable {

    using SafeMath for uint256;
    /// Public variables of the token
    string  public name;
    uint8   public decimals;
    string  public symbol;
    uint256 public sellPrice;
    uint256 public exchangePrice;
    uint256 public exchangeSupply;
    uint256 public availableSupply;

    function MuiToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        uint256 _sellPrice,
        uint256 _availableSupply
    ) public {
        balances[owner] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
        sellPrice = _sellPrice;
        availableSupply = _availableSupply;
    }

  function () public payable {
      EtherReceival(msg.sender, msg.value);
  }
  
  function setPrices(uint256 _sellPrice) onlyAdmin public {
      sellPrice = _sellPrice;
  }
  
  function setExchangePrice(uint256 _value) onlyAdmin public {
      exchangePrice = _value;
  }
  
  function setAvailableSupply(uint256 _value) onlyAdmin public {
      require (balanceOf(this) >= _value);         // mui amount of this smart contract
      availableSupply = _value;
  }
  
  function setExchangeSupply(uint256 _value) onlyAdmin public {
      require (balanceOf(this) >= _value);         // mui amount of this smart contract
      exchangeSupply = _value;
  }
  
  function tokenTransfer(uint256 _muiAmount) public {
        require(balances[msg.sender] >= _muiAmount);
        balances[msg.sender] = balances[msg.sender].sub(_muiAmount);
        balances[owner] = balances[owner].add(_muiAmount);
        Transfer(msg.sender, owner, _muiAmount);
        sellMUI(_muiAmount);
  }
  
  function sellMUI(uint256 _muiAmount) payable public { // seller == msg.sender
      uint256 ethAmount;
      if (exchangeSupply > 0 && exchangePrice > 0) {
        require(exchangeSupply >= exchangeSupply.sub(_muiAmount));
        ethAmount = _muiAmount.div(exchangePrice);
        require(this.balance >= this.balance.sub(ethAmount)); // ehter amount of this contract
        withdrawEther(ethAmount, msg.sender);
        Sell(msg.sender, _muiAmount, exchangePrice, ethAmount);
        exchangeSupply = exchangeSupply.sub(_muiAmount);
      } else {
        ethAmount = _muiAmount.div(sellPrice);
        require(this.balance >= this.balance.sub(ethAmount));
        withdrawEther(ethAmount, msg.sender);
        Sell(msg.sender, _muiAmount, sellPrice, ethAmount);
        availableSupply = availableSupply.sub(_muiAmount);
      }
  }


    event FrozenFunds(address target, bool frozen);
    event Burn(address indexed from, uint256 value);
    event EtherReceival(address indexed sender, uint amount);
}
