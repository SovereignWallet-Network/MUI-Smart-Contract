pragma solidity 0.4.24;


import "./ERC20.sol";


/**
 * @title Depositable
 * @dev Safe deposit pattern
 */
contract Depositable {

    event TokenDeposit(ERC20 token, address indexed from, uint256 amount);
    event EtherDeposit(address indexed from, uint256 amount);

    /**
     * @dev Deposits any kind of ERC20 compatible token to this contract
     * @notice In order this function works, `ERC20.approve()` should be called in advance
     * for this contract to transfer tokens on behalf of the token owner. Beware of
     * asynchronicity and do not call this function before `ERC20.approve()` is executed on the blockchain
     * @param token ERC20 The address of the token contract
     * @param sendFrom address Address of the sender
     * @param amount uint256 Amount of the token to be deposited to this contract
     */
    function depositToken(ERC20 token, address sendFrom, uint256 amount) internal {
        require(token.transferFrom(sendFrom, address(this), amount), "transferFrom function has been reverted!");
        emit TokenDeposit(token, sendFrom, amount);
    }

    /**
     * @dev Deposits ether to this contract
     * @notice If a contract is not desired to accept direct ether receivals
     * this function can be used for ether receivals by inheriting this contract
     * The reason why this pattern is used is because of preventing accidental
     * direct ether transactions to contracts in regard. 
     */
    function depositEther() public payable {
        emit EtherDeposit(msg.sender, msg.value);
    }
}
