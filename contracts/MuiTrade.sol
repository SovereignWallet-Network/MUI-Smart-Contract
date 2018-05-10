pragma solidity 0.4.19;


import "./SafeMath.sol";
import "./ERC20Interface.sol";
import "./Utils.sol";
import "./PermissionGroups.sol";
import "./Withdrawable.sol";


contract MuiTrade is Withdrawable,Utils {

  using SafeMath for uint256;

  ERC20   public muiToken;
  uint256 public sellPrice;
  uint256 public buyPrice;
  uint256 public exchangePrice;
  uint256 public exchangeSupply;
  uint256 public availableSupply;

  function MuiTrade(ERC20 _muiToken, address _admin, uint256 _buyPrice, uint256 _availableSupply) public {
      require(_admin != address(0));
      muiToken = _muiToken;
      admin = _admin;
      buyPrice = _buyPrice;
      availableSupply = _availableSupply;
  }

  function() public payable {
      EtherReceival(msg.sender, msg.value);
  }

  function setPrices(uint256 _buyPrice) onlyAdmin public {
      buyPrice  = _buyPrice;
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


  function buyMUI() payable public { // buyer == msg.spender && ethAmount == msg.value
      require(msg.value > 0);
      uint256 muiAmount = buyPrice.mul(msg.value);

      require(availableSupply > 0);
      require(availableSupply >= availableSupply.sub(muiAmount));
      require(muiToken.balanceOf(this) >= muiAmount);
      availableSupply = availableSupply.sub(muiAmount);
      withdrawToken(muiToken, muiAmount, msg.sender);
      Buy(msg.sender, muiAmount);
  }


  event EtherReceival(address indexed sender, uint amount);
  event Buy(address indexed _buyer, uint256 indexed _fund);
}
