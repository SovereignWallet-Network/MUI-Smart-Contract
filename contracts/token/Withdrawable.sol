pragma solidity 0.4.24;


import "./ERC20.sol";
import "../ownership/accessControl/PermissionGroups.sol";


/**
 * @title Withdrawable
 * @dev Safe withdrawal pattern
 */
contract Withdrawable is PermissionGroups {

    event TokenWithdraw(ERC20 token, address indexed sendTo, uint256 amount);
    event EtherWithdraw(address indexed sendTo, uint256 amount);

    /**
     * @dev Withdraws any kind of ERC20 compatible token
     * @param token ERC20 The address of the token contract
     * @param sendTo address Address of the recipient
     * @param amount uint256 Amount of the token to be withdrawn
     */
    function withdrawToken(ERC20 token, address sendTo, uint256 amount) internal {
        require(token.transfer(sendTo, amount));
        emit TokenWithdraw(token, sendTo, amount);
    }

    /**
     * @dev Withdraw Ethers
     * @param sendTo address Address of the recipient
     * @param amount uint256 Amount of ether to be withdrawn
     */
    function withdrawEther(address sendTo, uint256 amount) internal {
        sendTo.transfer(amount);
        emit EtherWithdraw(sendTo, amount);
    }

    /**
     * @dev Withdraws any kind of ERC20 compatible token only for the authorized callees
     * @param token ERC20 The address of the token contract
     * @param amount uint256 Amount of the token to be withdrawn
     */
    function withdrawTokenAuthorized(ERC20 token, uint256 amount) public onlyAdmin {
        require(token.transfer(msg.sender, amount));
        emit TokenWithdraw(token, msg.sender, amount);
    }

    /**
     * @dev Withdraw Ethers only for the authorized callees
     * @param amount uint256 Amount of ether to be withdrawn
     */
    function withdrawEtherAuthorized(uint256 amount) public onlyAdmin {
        msg.sender.transfer(amount);
        emit EtherWithdraw(msg.sender, amount);
    }
}
