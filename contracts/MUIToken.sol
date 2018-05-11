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
    string  public symbol;
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
    }


    event FrozenFunds(address target, bool frozen);
    event Sell(address indexed _seller, uint256 indexed _fund, uint256 indexed _sellPrice, uint256  _etherAmount);
}
