pragma solidity ^0.4.23;


import "./ERC20.sol";


/**
 * @title Withdrawable
 * @dev Safe withdrawal pattern
 */
contract Withdrawable {

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
}
