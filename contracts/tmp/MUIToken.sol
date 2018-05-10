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

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract EIP20Interface {
    uint256 public totalSupply;
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract EIP20 is EIP20Interface {

    using SafeMath for uint256;

    uint256 constant private MAX_UINT256 = 2**256 - 1;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= allowed[_from][msg.sender].sub(_value);
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        require(approve(_spender, _value));
        spender.receiveApproval(msg.sender, _value, this, _extraData);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
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

contract MuiToken is EIP20,Withdrawable {

    using SafeMath for uint256;
    string  public name;
    uint8   public decimals;
    string  public symbol;
    uint256 public sellPrice;
    uint256 public exchangePrice;
    uint256 public exchangeSupply;
    uint256 public availableSupply;

    function MuiToken() public {
        balances[admin] = 1000000000000000000000000000;
        totalSupply = 1000000000000000000000000000;
        name = "MUI";
        decimals = 18;
        symbol = "MUI";
        sellPrice = 6000;
        availableSupply = 10000000000000000000000000;
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
      uint256 _tmp = _value.mul(10**18);
      require (balanceOf(this) >= _tmp);
      availableSupply = _tmp;
  }

  function setExchangeSupply(uint256 _value) onlyAdmin public {
      uint256 _tmp = _value.mul(10**18);
      require (balanceOf(this) >= _tmp);
      exchangeSupply = _tmp;
  }

  function transferToSell(uint256 _muiAmount) public {
      require(balances[msg.sender] >= _muiAmount);
      sellMUI(_muiAmount);

      balances[msg.sender] = balances[msg.sender].sub(_muiAmount);
      balances[admin] = balances[admin].add(_muiAmount);
      Transfer(msg.sender, admin, _muiAmount);
  }

  function transferToSell_ON_REMIX(uint256 _muiAmount) public {
      uint256 _tmp = _muiAmount.mul(10**18);
      require(balances[msg.sender] >= _tmp);
      sellMUI(_tmp);

      balances[msg.sender] = balances[msg.sender].sub(_tmp);
      balances[admin] = balances[admin].add(_tmp);
      Transfer(msg.sender, admin, _tmp);
  }

  function sellMUI(uint256 _muiAmount) payable public {
      uint256 ethAmount;
      if (exchangeSupply > 0 && exchangePrice > 0) {
        require(exchangeSupply >= exchangeSupply.sub(_muiAmount));
        ethAmount = _muiAmount.div(exchangePrice);
        require(this.balance >= this.balance.sub(ethAmount));

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
  event EtherReceival(address indexed sender, uint amount);
}
