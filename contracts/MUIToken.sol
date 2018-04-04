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
    uint256 public bidPrice;

    uint256 public availableSupply;
    uint256 public bidSupply;

    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);
    event Buy(address indexed _buyer, uint256 indexed _fund);
    event Sell(address indexed _seller, uint256 indexed _fund, uint256 indexed _sellPrice, uint256  _etherAmount);   // _etherAmount : ether amount that user should received back 
    event Send(address indexed _from, address indexed _to, uint256 indexed _amount);

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

    function setPrices(uint256 _newSellPrice, uint256 _newBuyPrice) onlyOwner public {
        sellPrice = _newSellPrice;
        buyPrice  = _newBuyPrice;
    }
    
    function setBidPrice(uint256 _value) onlyOwner public {
        bidPrice = _value;
    }
    
    function setAvailableSupply(uint256 _value) onlyOwner public {
        require (balances[owner] >= _value);
        availableSupply = _value;
    }
    
    function setBidSupply(uint256 _value) onlyOwner public {
        require (balances[owner] >= _value);
        bidSupply = _value;
    }

    function buy(address _buyer, uint256 _amount) public {                      // _amount : amount of eth
        uint256 _muiAmount = _amount.mul(buyPrice);
        require(availableSupply > 0);
        require(availableSupply >= availableSupply.sub(_muiAmount));
        require(balances[owner] >= _muiAmount);
        availableSupply = availableSupply.sub(_muiAmount);
        _transfer(owner, _buyer, _muiAmount);
        Buy(_buyer, _muiAmount);
    }

    function sell(address _seller, uint256 _amount) public {                    // _amount : amount of mui
        uint256 _price;
        uint256 _etherAmount;
        uint256 _ownerBalance = owner.balance;
        
        if (bidSupply > 0) {
            require(bidSupply >= bidSupply.sub(_amount));
            _price = bidPrice;
            _etherAmount = _amount.div(_price);
            bidSupply = bidSupply.sub(_amount);
        } else {
            _price = sellPrice;
            _etherAmount = _amount.div(_price);
        }
        require(_ownerBalance >= _ownerBalance.sub(_etherAmount));              // ether
        require(balances[owner] >= _amount); 
        _transfer(_seller, owner, _amount);
        Sell(_seller, _amount, _price, _etherAmount);                           // prove the current sellPrice
    }

    function send(address _from, address _to, uint256 _amount) public {
        require(balances[_from] >= balances[_from].sub(_amount));
        _transfer(_from, _to, _amount);
        Send(_from, _to, _amount);
    }
}
