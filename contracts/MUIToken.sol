pragma solidity 0.4.19;


import "./SafeMath.sol";
import "./EIP20Interface.sol";
import "./EIP20.sol";
import "./PermissionGroups.sol";


contract MuiToken is EIP20,PermissionGroups {

    using SafeMath for uint256;

    function () {
        /// if ether is sent to this address, send it back.
        throw;
    }

    /// Public variables of the token
    string  public name;
    uint8   public decimals;
    string  public symbol;

    function MuiToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
    ) public {
        balances[admin] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
    }

    function mintToken(address _target, uint256 _mintedAmount) onlyAdmin public {
        balances[_target] = balances[_target].add(_mintedAmount);
        totalSupply = totalSupply.add(_mintedAmount);
        Transfer(0, this, _mintedAmount);
        Transfer(this, _target, _mintedAmount);
    }

    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);
        require(_value <= allowed[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(_from, _value);
        return true;
    }

    event FrozenFunds(address target, bool frozen);
    event Burn(address indexed from, uint256 value);
}
