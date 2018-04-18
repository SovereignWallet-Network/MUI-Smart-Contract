pragma solidity 0.4.19;

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

  /**
   * @dev Allows the current admin to set the pendingAdmin address.
   * @param newAdmin The address to transfer ownership to.
   */
  function transferAdmin(address _newAdmin) public onlyAdmin {
      require(_newAdmin != address(0));
      TransferAdminPending(pendingAdmin);
      pendingAdmin = newAdmin;
  }

  /**
   * @dev Allows the current admin to set the admin in one tx. Useful initial deployment.
   * @param newAdmin The address to transfer ownership to.
   */
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

    function withdrawToken(ERC20 _token, uint _amount, address _sendTo) external {
        require(_token.transfer(_sendTo, _amount));
        TokenWithdraw(_token, _amount, _sendTo);
    }

    function withdrawEther(uint _amount, address _sendTo) external {
        _sendTo.transfer(_amount);
        EtherWithdraw(_amount, _sendTo);
    }

    event TokenWithdraw(ERC20 token, uint amount, address sendTo);
    event EtherWithdraw(uint amount, address sendTo);
}

contract muiWallet is Withdrawable,Utils {

  ERC20   public muiToken;
  uint256 public sellPrice;
  uint256 public buyPrice;
  uint256 public exchangePrice;
  uint256 public availableSupply;
  mapping(address=>bool) public isReserve;

  function muiWallet(ERC20 _muiToken, address _admin, uint256 _sellPrice, uint256 _buyPrice, uint256 _availableSupply) public {
      require(_admin != address(0));
      muiToken = _muiToken;
      admin = _admin;
      sellPrice = _sellPrice;
      buyPrice = _buyPrice;
      availableSupply = _availableSupply;
  }

  function() public payable {
      require(isReserve[msg.sender]);
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
          require (muiToken.balanceOf(admin) >= _value);
          availableSupply = _value;
  }

  function getBalance(ERC20 _token, address _user) public view returns(uint) {
      if (_token == ETH_TOKEN_ADDRESS)
          return _user.balance;
      else
          return _token.balanceOf(_user);
  }

  function buyMUI(address _buyer, uint256 _ethAmount) public {
      uint256 muiAmount = _amount.mul(buyPrice);
      require(availableSupply > 0);
      require(availableSupply >= availableSupply.sub(muiAmount));
      require(muiToken.balanceOf(this) >= muiAmount);
      availableSupply = availableSupply.sub(muiAmount);
  }

  function sellMUI(address _seller, uint256 _muiAmount) public {

  }

  event EtherReceival(address indexed sender, uint amount);
  // send() // ERC20 의 transfer() function 으로 Token 보내볼 것 (Client)
}
