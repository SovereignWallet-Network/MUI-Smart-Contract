pragma solidity 0.4.19;

import "./PausableToken.sol";
import "../ownership/Claimable.sol";
import "./BulkTransferable.sol";

/**
 * @title MuiToken
 * @dev SovereignWallet Network token
 */
contract MuiToken is PausableToken, BulkTransferable, Claimable {
    // TODO: Set the constants later
    string public constant name = "MuiToken";
    string public constant symbol = "MUI";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(decimals));

    /**
     * @dev Constructor function of the contract
     * @dev In the deployment immideately give all the tokens to the supplier
     * @param supplier address Address of the supplier
     */
    function MuiToken(address supplier) public {
        totalSupply_ = INITIAL_SUPPLY;
        // Give all the supply to the supplier
        balances[supplier] = INITIAL_SUPPLY;
        Transfer(0x0, supplier, INITIAL_SUPPLY);
    }


    // TODO: Research for an efficient way to handle transfers at once instead of looping through????
    function bulkTransfer(address[] addrList, uint256[] valueList) external {
        require(addrList.length == valueList.length);
        for (uint256 i = 0; i < addrList.length; i++) {
            super.transfer(addrList[i], valueList[i]);
        }
    }
}
