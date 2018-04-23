pragma solidity 0.4.19;


import "./SafeMath.sol";
import "./ERC20Interface.sol";
import "./Utils.sol";
import "./PermissionGroups.sol";
import "./Withdrawable.sol";


contract muiWallet is Withdrawable,Utils {

  using SafeMath for uint256;

  ERC20   public muiToken;
  uint256 public sellPrice;
  uint256 public buyPrice;
  uint256 public exchangePrice;
  uint256 public exchangeSupply;
  uint256 public availableSupply;
  //mapping(address=>bool) public isReserve; // @TODO : Will be implemented in the future after figuring what the feature of reserve and how it works

  function muiWallet(ERC20 _muiToken, address _admin, uint256 _sellPrice, uint256 _buyPrice, uint256 _availableSupply) public {
      require(_admin != address(0));
      muiToken = _muiToken;
      admin = _admin;
      sellPrice = _sellPrice;
      buyPrice = _buyPrice;
      availableSupply = _availableSupply;
  }

  function() public payable {
      //require(isReserve[msg.sender]);
      EtherReceival(msg.sender, msg.value);
  }

  function setPrices(uint256 _sellPrice, uint256 _buyPrice) onlyAdmin public {
      sellPrice = _sellPrice;
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

  function getBalance(ERC20 _token, address _user) public view returns(uint) {
      if (_token == ETH_TOKEN_ADDRESS)
          return _user.balance;
      else
          return _token.balanceOf(_user);
  }

  function buyMUI() payable public { // buyer == msg.spender && ethAmount == msg.value
      uint256 muiAmount = buyPrice.mul(msg.value);

      require(availableSupply > 0);
      require(availableSupply >= availableSupply.sub(muiAmount));
      require(muiToken.balanceOf(this) >= muiAmount);
      availableSupply = availableSupply.sub(muiAmount);
      withdrawToken(muiToken, muiAmount, msg.sender);
      Buy(msg.sender, muiAmount);
  }

  function sellMUI(uint256 _muiAmount) public { // seller == msg.sender
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

  function sendMUI(address _to, uint256 _muiAmount) public {  // _from == msg.sender
      require(muiToken.balanceOf(msg.sender) >= muiToken.balanceOf(msg.sender).sub(_muiAmount));
      withdrawToken(muiToken, _muiAmount, _to);
      Send(msg.sender, _to, _muiAmount);
  }

  event EtherReceival(address indexed sender, uint amount);
  event Buy(address indexed _buyer, uint256 indexed _fund);
  event Sell(address indexed _seller, uint256 indexed _fund, uint256 indexed _sellPrice, uint256  _etherAmount);   // _etherAmount : ether amount that user should received back
  event Send(address indexed _from, address indexed _to, uint256 indexed _amount);
}
