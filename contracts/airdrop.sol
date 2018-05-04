pragma solidity 0.4.19;


import "./ERC20Interface.sol";
import "./PermissionGroups.sol";
import "./incentiveSystems/friendRequest.sol";
import "./incentiveSystems/join.sol";
import "./incentiveSystems/buyToken.sol";
import "./incentiveSystems/sellToken.sol";
import "./incentiveSystems/sendFriends.sol";


contract Airdrop is PermissionGroups, friendRequest, join, buyToken, sellToken, sendFriends {

  ERC20   public muiToken;
  uint256 public walletIncentive = 10;
  uint256 public externalIncentive = 10;

  function Airdrop(ERC20 _muiToken, address _admin) public {
      muiToken = _muiToken;
      admin = _admin;
  }

  function setWalletIncentive(uint256 _value) onlyAdmin public {
      walletIncentive = _value;
 }

  function setExternalIncentive(uint256 _value) onlyAdmin public {
      externalIncentive = _value;
 }

  //app internal
  function sovereignFriendRequestAirdrop(address _to) onlyAdmin public {
      require (muiToken.balanceOf(this) >= walletIncentive);
      friendRequestEvent(msg.sender, _to);
      require(muiToken.transfer(msg.sender, walletIncentive));
      TokenWithdraw(muiToken, walletIncentive, msg.sender);
  }

  function sovereignJoinAirdrop() onlyAdmin public {
      require (muiToken.balanceOf(this) >= walletIncentive);
      joinEvent(msg.sender);
      require(muiToken.transfer(msg.sender, walletIncentive));
      TokenWithdraw(muiToken, walletIncentive, msg.sender);
  }

  function sovereignBuyTokenAirdrop() onlyAdmin public {
      require (muiToken.balanceOf(this) >= walletIncentive);
      buyEvent(msg.sender);
      require(muiToken.transfer(msg.sender, walletIncentive));
      TokenWithdraw(muiToken, walletIncentive, msg.sender);
  }
   
  function sovereignSellTokenAirdrop() onlyAdmin public {
      require (muiToken.balanceOf(this) >= walletIncentive);
      sellEvent(msg.sender);
      require(muiToken.transfer(msg.sender, walletIncentive));
      TokenWithdraw(muiToken, walletIncentive, msg.sender);
  }

  function sovereignSendFriendsAirdrop(address _to) onlyAdmin public {
      require (muiToken.balanceOf(this) >= walletIncentive);
      sendFriendsEvent(msg.sender, _to);
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
