pragma solidity 0.4.19;


import "./ERC20Interface.sol";
import "./PermissionGroups.sol";

contract Airdrop is PermissionGroups {

  ERC20   public muiToken;
  address public admin;
  uint256 public walletIncentive = 10;
  uint256 public externalIncentive = 10;

  function Airdrop(ERC20 _muiToken, address _admin) public {
      muiToken = _muiToken;
      admin = _admin;
  }

    //app internal
  function sovereignTransfer() public {
      require (muiToken.balanceOf(this) >= walletIncentive);
      require(muiToken.transfer(msg.sender, walletIncentive)); 
      TokenWithdraw(muiToken, walletIncentive, msg.sender);
  }
    
    //airdrop event
  function externalTransfer(address _to) onlyAdmin public {
      require (muiToken.balanceOf(this) >= externalIncentive);
      require(muiToken.transfer(_to, externalIncentive)); 
      TokenWithdraw(muiToken, externalIncentive, _to);
  }

  event TokenWithdraw(ERC20 token, uint256 amount, address sendTo);
}
