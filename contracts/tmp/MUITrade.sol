pragma solidity 0.4.19;

// REMIX IDE ERR 로 인한 TMP SMART CONTRACT : INPUT VLAUE 로 10**18 이상의 Big Number 가 입력되지 않음

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

interface ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf(address _owner) public view returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    function decimals() public view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract Utils {
    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    uint  constant internal MAX_DECIMALS = 18;
    uint  constant internal ETH_DECIMALS = 18;
    mapping(address=>uint) internal decimals;

    function getBalance(ERC20 _token, address _user) public view returns(uint) {
      if (_token == ETH_TOKEN_ADDRESS)
          return _user.balance;
      else
          return _token.balanceOf(_user);
    }
}

contract PermissionGroups {

  address public admin;
  address public pendingAdmin;
  mapping (address => bool) public frozenAccount;
  mapping(address=>bool) internal operators;
  address[] internal operatorsGroup;
  uint constant internal MAX_GROUP_SIZE = 50;

  function PermissionGroups() public {
      admin = msg.sender;
  }

  modifier onlyAdmin() {
      require(msg.sender == admin);
      _;
  }

  modifier onlyOperator() {
      require(operators[msg.sender]);
      _;
  }

  function getOperators () external view returns(address[]) {
      return operatorsGroup;
  }

  function transferAdmin(address _newAdmin) public onlyAdmin {
      require(_newAdmin != address(0));
      TransferAdminPending(pendingAdmin);
      pendingAdmin = _newAdmin;
  }

  function transferAdminQuickly(address newAdmin) public onlyAdmin {
      require(newAdmin != address(0));
      TransferAdminPending(newAdmin);
      AdminClaimed(newAdmin, admin);
      admin = newAdmin;
  }

  function claimAdmin() public {
      require(pendingAdmin == msg.sender);
      AdminClaimed(pendingAdmin, admin);
      admin = pendingAdmin;
      pendingAdmin = address(0);
  }

  function addOperator(address newOperator) public onlyAdmin {
      require(!operators[newOperator]); // prevent duplicates.
      require(operatorsGroup.length < MAX_GROUP_SIZE);

      OperatorAdded(newOperator, true);
      operators[newOperator] = true;
      operatorsGroup.push(newOperator);
  }

  function removeOperator (address operator) public onlyAdmin {
      require(operators[operator]);
      operators[operator] = false;

      for (uint i = 0; i < operatorsGroup.length; ++i) {
          if (operatorsGroup[i] == operator) {
              operatorsGroup[i] = operatorsGroup[operatorsGroup.length - 1];
              operatorsGroup.length -= 1;
              OperatorAdded(operator, false);
              break;
          }
      }
  }

  function killAdmin() onlyAdmin {
      suicide(admin);
  }

  function freezeAccount(address _target, bool _freeze) public onlyAdmin {
      frozenAccount[_target] = _freeze;
      FrozenFunds(_target, _freeze);
  }

  event TransferAdminPending(address pendingAdmin);
  event AdminClaimed( address newAdmin, address previousAdmin);
  event OperatorAdded(address newOperator, bool isAdd);
  event FrozenFunds(address target, bool frozen);
}

contract Withdrawable is PermissionGroups {

    function withdrawToken(ERC20 _token, uint _amount, address _sendTo) public {
        require(_token.transfer(_sendTo, _amount));
        TokenWithdraw(_token, _amount, _sendTo);
    }

    function withdrawEther(uint _amount, address _sendTo) public {
        _sendTo.transfer(_amount);
        EtherWithdraw(_amount, _sendTo);
    }

    event TokenWithdraw(ERC20 token, uint amount, address sendTo);
    event EtherWithdraw(uint amount, address sendTo);
}

contract MuiTrade is Withdrawable,Utils {

  using SafeMath for uint256;

  ERC20   public muiToken;
  uint256 public buyPrice = 6000;
  uint256 public exchangePrice;
  uint256 public exchangeSupply;
  uint256 public availableSupply = 10000000000000000000000000;

  function MUITrade(ERC20 _muiToken, address _admin, uint256 _buyPrice, uint256 _availableSupply) public {
      require(_admin != address(0));
      muiToken = _muiToken;
      admin = _admin;
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
      uint256 _tmp = _value.mul(10**18);
      require (muiToken.balanceOf(this) >= _tmp);
      availableSupply = _tmp;
  }

  function setExchangeSupply(uint256 _value) onlyAdmin public {
      require (muiToken.balanceOf(this) >= _value);
      exchangeSupply = _value;
  }


  function buyMUI() payable public {
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
