pragma solidity 0.4.24;

import "./ACB.sol";

/**
 * @title PhaseBased
 * @dev Allows phase-based operation in Algorithmic Central Bank.
 */
contract PhaseBasedACB is ACB {

    uint256 public phaseStartTime = 0;
    uint256 public phaseEndTime = 0;
    uint256 public phaseIndex = 0;
    uint256 public initialBuySupplyACB = 0;
    uint256 public initialSellSupplyACB = 0;


    /**
     * @dev Modifier to make a function callable only when the phase is active
     */
    modifier whenPhaseActive() {
        require(phaseStartTime < now && phaseEndTime > now);
        require(sellSupplyACB.add(buySupplyACB) > 0);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the phase is deactive
     */
    modifier whenPhaseDeactive() {
        // Check both conditions that the phase has already finished & it hasn't started yet
        require(phaseStartTime > now || phaseEndTime < now);
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
     */
    constructor(
        address tokenAddress, 
        uint256 initialBuyPrice, 
        uint256 initialSellPrice) 
        public payable ACB(tokenAddress, initialBuyPrice, initialSellPrice)
    {}

    /**
     * @dev Checks whether the current phase is active or not
     */
    function isPhaseActive() public view returns (bool) {
        return phaseStartTime < now 
            && phaseEndTime > now 
            && sellSupplyACB.add(buySupplyACB) > 0;
    }

    /**
     * @dev Sets a sale phase.
     * @param startTime uint256 The start time of sale phase
     * @param endTime uint256 The end time of sale phase
     * @param buySupplyACB uint256 Available token supply that ACB can buy up to in this phase
     * @param sellSupplyACB uint256 Available token supply that ACB can sell up to in this phase
     * @param buyPriceACB uint256 The price at which ACB buys in this phase
     * @param sellPriceACB uint256 The price at which ACB sells in this phase
     */
    function setSalePhase(
        uint256 startTime, 
        uint256 endTime, 
        uint256 buySupplyACB, 
        uint256 sellSupplyACB, 
        uint256 buyPriceACB, 
        uint256 sellPriceACB) public onlyAdmin whenPhaseDeactive 
    {
        // Do not change this order. Price should be set before supply
        setPhasePeriod(startTime, endTime);
        super.setPrices(buyPriceACB, sellPriceACB);
        super.setAvailableSupplies(buySupplyACB, sellSupplyACB);
        
        initialBuySupplyACB = buySupplyACB;
        initialSellSupplyACB = sellSupplyACB;
        phaseIndex++;
    }

    /**
     * @dev Sets the start and end time of sale phase
     * @param startTime uint256 The start time of sale phase
     * @param endTime uint256 The end time of sale phase
     */
    function setPhasePeriod(uint256 startTime, uint256 endTime) public onlyAdmin {
        // Do not allow to set start & end time to a value in past
        require(startTime > now && endTime > now);
        require(endTime > startTime);

        phaseStartTime = startTime;
        phaseEndTime = endTime;
    }

    function buyFromACB() public payable whenPhaseActive onlyWhiteListed {
        super.buyFromACB();
    }

    function sellToACB(uint256 tokenAmount) public whenPhaseActive onlyWhiteListed {
        super.sellToACB(tokenAmount);
    }

    /**
     * @dev This allows admins to buy tokens in any time regardless of phase
     */
    function buyBack() public payable onlyAdmin {
        super.buyFromACB();
    }
}
