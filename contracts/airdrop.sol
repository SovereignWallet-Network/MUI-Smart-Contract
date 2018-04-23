pragma solidity 0.4.19;


import "./ERC20Interface.sol";

contract airdrop {

  ERC20   muiToken;
  address admin;
  uint256 walletIncentive = 10;
  uint256 externalIncentive = 10;

  function airdrop(ERC20 _muiToken, address _admin) public {
      muiToken = _muiToken;
      admin = _admin;
  }

  modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }

  function transferOwnership(address newAdmin) onlyAdmin public {
        admin = newAdmin;
  }

  function setWalletIncentive(uint256 _value) onlyAdmin public {
      walletIncentive = _value;
  }

  function setExternalIncentive(uint256 _value) onlyAdmin public {
      externalIncentive = _value;
  }

    //app internal
  function sovereignTransfer() public {
      require (muiToken.balanceOf(this) >= _value);
      require(muiToken.transfer(msg.sender, walletIncentive)); 
      TokenWithdraw(muiToken, walletIncentive, msg.sender);
  }
    
    //airdrop event
  function extalTransfer() public {
      require (muiToken.balanceOf(this) >= _value);
      require(muiToken.transfer(msg.sender, externalIncentive)); 
      TokenWithdraw(muiToken, externalIncentive, msg.sender);
  }

  event TokenWithdraw(ERC20 token, uint amount, address sendTo);
}
