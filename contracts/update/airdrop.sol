pragma solidity 0.4.19;


contract airdrop{

  using SafeMath for uint256;
  ERC20   public muiToken;

  function muiWallet(ERC20 _muiToken, address _admin, uint256 _amount) public {
      require(_admin != address(0));
      muiToken = _muiToken;
      admin = _admin;
      amount =_amount;
  }

  function sovereignTransfer(address _to, uint256 _value) public returns (bool success) {
      require(balances[msg.sender] >= _value);
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      Transfer(msg.sender, _to, _value);
      return true;
  }

  function extalTransfer(address _to, uint256 _value) public returns (bool success) {
      require(balances[msg.sender] >= _value);
      balances[msg.sender] = balances[msg.sender].sub(_value);
      balances[_to] = balances[_to].add(_value);
      Transfer(msg.sender, _to, _value);
      return true;
  }
}
