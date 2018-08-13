pragma solidity 0.4.24;

import "../PhaseBasedACB.sol";


/**
 * @title MockACB
 * @dev A contract to mock Algorithmic Central Bank (for tests)
 */
contract MockACB is PhaseBasedACB {

    constructor(
        address tokenAddress, 
        uint256 initialBuyPrice, 
        uint256 initialSellPrice) 
        public payable PhaseBasedACB(tokenAddress, initialBuyPrice, initialSellPrice)
    {}

    function moveTimeBeyondPhaseStart(uint256 _seconds) public {
        phaseStartTime = now.sub(_seconds);   // rewind start time by _seconds
    }

    function moveTimeBeyondPhaseEnd(uint256 _seconds) public {
        phaseStartTime = now.sub(_seconds.mul(10));  //rewind start time by 10 * _seconds
        phaseEndTime = now.sub(_seconds);   // rewind end time by _seconds
    }
}
