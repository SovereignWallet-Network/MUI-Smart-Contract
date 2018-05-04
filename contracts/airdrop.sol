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
  function sovereignFriendRequestAirdrop(address _from, address _to) onlyAdmin public {
      require (muiToken.balanceOf(this) >= walletIncentive);
      friendRequestEvent(_from, _to);
      require(muiToken.transfer(_from, walletIncentive));
      TokenWithdraw(muiToken, walletIncentive, _from);
  }

  function sovereignJoinAirdrop(address _from) onlyAdmin public {
      require (muiToken.balanceOf(this) >= walletIncentive);
      joinEvent(_from);
      require(muiToken.transfer(_from, walletIncentive));
      TokenWithdraw(muiToken, walletIncentive, _from);
  }

  function sovereignBuyTokenAirdrop(address _from) onlyAdmin public {
      require (muiToken.balanceOf(this) >= walletIncentive);
      buyEvent(_from);
      require(muiToken.transfer(_from, walletIncentive));
      TokenWithdraw(muiToken, walletIncentive, _from);
  }
   
  function sovereignSellTokenAirdrop(address _from) onlyAdmin public {
      require (muiToken.balanceOf(this) >= walletIncentive);
      sellEvent(_from);
      require(muiToken.transfer(_from, walletIncentive));
      TokenWithdraw(muiToken, walletIncentive, _from);
  }

  function sovereignSendFriendsAirdrop(address _from, address _to) onlyAdmin public {
      require (muiToken.balanceOf(this) >= walletIncentive);
      sendFriendsEvent(_from, _to);
      require(muiToken.transfer(_from, walletIncentive));
      TokenWithdraw(muiToken, walletIncentive, _from);
  }

  //airdrop event
  function externalTransfer(address _to) onlyAdmin public {
      require (muiToken.balanceOf(this) >= externalIncentive);
      require(muiToken.transfer(_to, externalIncentive));
      TokenWithdraw(muiToken, externalIncentive, _to);
  }

  event TokenWithdraw(ERC20 token, uint256 amount, address sendTo);
}
