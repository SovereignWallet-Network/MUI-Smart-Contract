pragma solidity ^0.4.23;

import "../ownership/Ownable.sol";
import "../token/ERC20.sol";


/**
 * @title TokenDestructible
 * @dev Base contract that can be destroyed by owner 
 * and all funds in the contract including the listed 
 * tokens will be sent to the owner or the address provided.
 */
contract Destructible is Ownable {

    function() public payable { }

    /**
     * @dev Terminates the contract and refunds to owner
     * @param tokens address[] List of addresses of ERC20 token contracts to refund.
     * @notice The called token contracts could try to re-enter this contract. 
     * Only supply token contracts you trust.
     */
    function destroy(address[] tokens) onlyOwner public {
        // Transfer tokens to owner
        clearAllTokens(tokens, owner);
        // Transfer Eth to owner and terminate contract
        selfdestruct(owner);
    }

    /**
     * @dev Terminates the contract and refunds the address provided
     * @param tokens address[] List of addresses of ERC20 token contracts to refund.
     * @param recipient address Address that the refund to be made
     * @notice The called token contracts could try to re-enter this contract. 
     * Only supply token contracts you trust.
     */
    function destroyAndSend(address[] tokens, address recipient) onlyOwner public {
        // Transfer tokens to owner
        clearAllTokens(tokens, recipient);
        // Transfer Eth to owner and terminate contract
        selfdestruct(recipient);
    }

    /**
     * @dev Refunds all the listed ERC20 tokens to the provided address
     * @param tokens address[] List of addresses of ERC20 token contracts to refund.
     * @param recipient address Address that the refund to be made
     */
    function clearAllTokens(address[] tokens, address recipient) private {
        for (uint256 i = 0; i < tokens.length; i++) {
            ERC20 token = ERC20(tokens[i]);
            uint256 balance = token.balanceOf(this);
            token.transfer(recipient, balance);
        }
    }
}
