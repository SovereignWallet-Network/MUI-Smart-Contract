pragma solidity ^0.4.23;

import "./ACB.sol";

/**
 * @title PhaseBased
 * @dev Allows phase-based operation in Algorithmic Central Bank.
 */
contract PhaseBasedACB is ACB {

    uint256 public phaseStartTime = 0;
    uint256 public phaseEndTime = 0;


    /**
     * @dev Modifier to make a function callable only when the phase is active
     */
    modifier whenPhaseActive() {
        require(phaseStartTime < now && phaseEndTime > now);
        require(sellSupplyACB.add(buySupplyACB) > 0);
        _;
    }


    /**
     * @dev Constructor
     * @notice The contract can be funded with ether at the deployment time.
     * @notice The supplies must be set after the deployment because the funding
     * with the token in regard is not supported at the deployment time.
     * @notice Also fee rate can be set after the deployment too.
     * @param tokenAddress address Address of ERC20 compliant token to be traded
     * @param initialBuyPrice uint256 Initial buy price of ACB for the intended token
     * @param initialSellPrice uint256 Initial sell price of ACB for the intended token
     * @param startTime uint256 Start time of the initial trading phase
     * @param endTime uint256 End time of the initial trading phase
     */
    constructor(
        address tokenAddress, 
        uint256 initialBuyPrice, 
        uint256 initialSellPrice, 
        uint256 startTime, 
        uint256 endTime) 
        public payable ACB(tokenAddress, initialBuyPrice, initialSellPrice)
    {
        setPhasePeriod(startTime, endTime);
    }

    /**
     * @dev Checks whether the current phase is active or not
     */
    function isPhaseActive() public view returns (bool) {
        return phaseStartTime < now 
            && phaseEndTime > now 
            && sellSupplyACB.add(buySupplyACB) > 0;
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

    function buyFromACB(uint256 tokenAmount) public payable whenPhaseActive onlyWhiteListed {
        super.buyFromACB(tokenAmount);
    }

    function sellToACB(uint256 tokenAmount) public whenPhaseActive onlyWhiteListed {
        super.sellToACB(tokenAmount);
    }
}
