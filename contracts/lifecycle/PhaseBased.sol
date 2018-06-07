pragma solidity ^0.4.23;

import "../ownership/accessControl/PermissionGroups.sol";

/**
 * @title PhaseBased
 * @dev Allows phase based operation.
 */
contract PhaseBased is PermissionGroups {

    uint256 public phaseStartTime = 0;
    uint256 public phaseEndTime = 0;


    /**
     * @dev Modifier to make a function callable only when the phase is active
     * @param supply uint256 Total supply for the phase
     */
    modifier whenPhaseActive(uint256 supply) {
        require(phaseStartTime < now && phaseEndTime > now);
        require(supply > 0);
        _;
    }

    /**
     * @dev Sets the start and end time of trade phase
     * @param startTime uint256 The start time of trade phase
     * @param endTime uint256 The end time of trade phase
     */
    function setPhasePeriod(uint256 startTime, uint256 endTime) public onlyAdmin {
        // Do not allow to set start & end time to a value in past
        require(startTime > now && endTime > now);
        require(endTime > startTime);

        phaseStartTime = startTime;
        phaseEndTime = endTime;
    }
}
