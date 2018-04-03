pragma solidity 0.4.19;

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }

}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract MUIToken is owned,StandardToken {

    using SafeMath for uint256;

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Public variables of the token */
    uint256 public supplyAmount = 10000000000000000000000000;
    string  public name;
    uint8   public decimals;
    string  public symbol;

    uint256 public sellPrice;
    uint256 public buyPrice;

    uint256 public availableSupply;

    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);
    event Buy(address _buyer, uint256 _fund);
    event Sell(address _seller, uint256 _fund, uint256 _sellPrice);
    event Send(address _from, address _to, uint256 _amount);

    function MUIToken(
        ) {
        totalSupply = supplyAmount;
        balances[owner] = totalSupply;
        name = "MUI";
        decimals = 18;
        symbol = "MUI";
        availableSupply = 0;
    }

    function _transfer(address _from, address _to, uint256 _value) internal {
        require (_to != 0x0);                                                   // Prevent transfer to 0x0 address. Use burn() instead
        require (balances[_from] >= _value);                                    // Check if the sender has enough
        require (balances[_to].add(_value) > balances[_to]);                    // Check for overflows
        require(!frozenAccount[_from]);                                         // Check if sender is frozen
        require(!frozenAccount[_to]);                                           // Check if recipient is frozen
        balances[_from] = balances[_from].sub(_value);                          // Subtract from the sender
        balances[_to] = balances[_to].add(_value);                              // Add the same to the recipient
        Transfer(_from, _to, _value);
    }

    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balances[target] = balances[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }

    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    function setAvailableSupply(uint256 _value) onlyOwner public {
        require (balances[owner] >= _value);
        availableSupply = _value;
    }

    function buy(address _buyer, uint256 _amount) public {
        require(availableSupply > 0);
        require(availableSupply >= availableSupply.sub(_amount));
        require(balances[owner] >= _amount);
        availableSupply = availableSupply.sub(_amount);
        _transfer(owner, _buyer, _amount);
        Buy(_buyer, _amount);
    }

    function sell(address _seller, uint256 _amount) public {
        require(balances[owner] >= _amount);
        _transfer(_seller, owner, _amount);
        Sell(_seller, _amount, sellPrice);                                       // prove the current sellPrice
    }

    function send(address _from, address _to, uint256 _amount) public {
        _transfer(_from, _to, _amount);
        Send(_from, _to, _amount);
    }
}
