pragma solidity 0.4.19;


import "./SafeMath.sol";
import "./EIP20Interface.sol";
import "./ERC20Interface.sol";
import "./EIP20.sol";
import "./PermissionGroups.sol";
import "./Withdrawable.sol";

contract MuiToken is EIP20, PermissionGroups, Withdrawable {

    using SafeMath for uint256;
    /// Public variables of the token
    string  public name;
    uint8   public decimals;
    uint256 public sellPrice;
    string  public symbol;
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
        availableSupply =  _availableSupply;
    }

    function() public payable {
        EtherReceival(msg.sender, msg.value);
    }

    function setPrices(uint256 _sellPrice) onlyAdmin public {
        sellPrice = _sellPrice;
    }

    function setExchangePrice(uint256 _value) onlyAdmin public {
        exchangePrice = _value;
    }

    function setAvailableSupply(uint256 _value) onlyAdmin public {
        require (muiToken.balanceOf(this) >= _value);         // mui amount of this smart contract
        availableSupply = _value;
    }

    function setExchangeSupply(uint256 _value) onlyAdmin public {
        require (muiToken.balanceOf(this) >= _value);         // mui amount of this smart contract
        exchangeSupply = _value;
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
    event Sell(address indexed _seller, uint256 indexed _fund, uint256 indexed _sellPrice, uint256  _etherAmount);
}
