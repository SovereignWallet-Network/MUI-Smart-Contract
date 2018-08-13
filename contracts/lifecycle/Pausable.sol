pragma solidity 0.4.24;

/**
 * In this commit latest commit, Pausable is changed to PermissionGroup instead of Ownable
 * Because in backend side integration of Airdrop contract, the backend needs to call 
 * pause/unpause txns, and we better have an admin role for this txns rather than owner.
 * For the ACB and MUIToken, please refer to the prevoius commits
 */
import "../ownership/accessControl/PermissionGroups.sol";


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PermissionGroups {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
      * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused, "Already paused!");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused, "Already unpaused!");
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyAdmin whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyAdmin whenPaused {
        paused = false;
        emit Unpause();
    }
}
