pragma solidity ^0.4.23;


/**
 * @title PositiveMath
 */
library PositiveMath {

    /**
     * @dev Increments the given positive integer by one
     */
    function increment(uint256 a) internal pure returns(uint256 b) {
        require(a >= 0);
        b = a + 1;
        assert(b > 0);
        return b;
    }

    /**
     * @dev Decrements the given positive integer by one. 
     */
    function decrement(uint256 a) internal pure returns(uint256) {
        require(a >= 0);
        return a == 0 ? 0 : a - 1;
    }
}
