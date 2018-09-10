pragma solidity 0.4.24;

import "./utils/SafeMath.sol";
import "./token/ERC20.sol";
import "./token/Withdrawable.sol";
import "./lifecycle/Destructible.sol";
import "./lifecycle/Pausable.sol";


contract FeeCollector is Withdrawable, Destructible, Pausable {
    using SafeMath for uint256;

    event FeeCollected(address indexed feeAsset, address indexed from, uint256 feeAmount);


    /**
     * @dev Expects the fee to be sent alongside with the transcation in ether. In case of token transfers,
     *      the ether amount sent alongside with the transaction is taken as fee and it should be equal to
     *      or greater than the fee amount. Otherwise the transaction will be reverted. In case of ether transfers,
     *      token address should be passed as 0x0 and amount parameter will be ignored. 
     * @param token address Address of the ERC20 token to be transferred. Pass as 0x0 in case of ether transfers
     * @param to address Address of te recipient
     * @param amount uint256 Amount of the incoming transfer. Ignored in case of ether transfers
     * @param feeAmount uint256 Amount of the fee to be deducted from the amount of the incoming transfer
     */
    function transferAndChargeByEther(address token, address to, uint256 amount, uint256 feeAmount) public payable {
        require(msg.value >= feeAmount, "Ether amount is not enough for fee payment!");

        if (token == address(0)) {
            transferAndChargeByAmountAsEther(to, msg.value, feeAmount);
        } else {
            require(ERC20(token).transferFrom(msg.sender, to, amount), "Cannot transfer asset to the recipient!");
            emit FeeCollected(token, msg.sender, feeAmount);
        }
    }

    /**
     * @dev Deducts the provided amount of fee (in the same asset as the transferred one)
     *      from the total amount given. In case of ether transfers, token address
     *      should be passed as 0x0 and amount parameter will be ignored. The ether amount
     *      sent alongside with the transaction should be greater than the fee amount.
     *      Otherwise transaction will be reverted.
     * @param token address Address of the ERC20 token to be transferred. Pass 0x0 in case of ether transfers
     * @param to address Address of te recipient
     * @param amount uint256 Amount of the incoming transfer. Ignored in case of ether transfers
     * @param feeAmount uint256 Amount of the fee to be deducted from the amount of the incoming transfer
     */
    function transferAndChargeByAmount(address token, address to, uint256 amount, uint256 feeAmount) public payable {
        if (token == address(0)) {
            transferAndChargeByAmountAsEther(to, msg.value, feeAmount);
        } else {
            transferAndChargeByAmountAsToken(token, msg.sender, to, amount, feeAmount);
        }
    }

    /**
     * @dev Deducts the provided percent of fee (in the same asset as the transferred one)
     *      from the total amount given. In case of ether transfers, token address should
     *      be passed as 0x0 and amount parameter will be ignored. The ether amount sent
     *      alongside with the transaction should be greater than the fee amount
     *      calculated by the percent. Otherwise transaction will be reverted.
     * @param token address Address of the ERC20 token to be transferred. Pass 0x0 in case of ether transfers
     * @param to address Address of te recipient
     * @param amount uint256 Amount of the incoming transfer. Ignored in case of ether transfers
     * @param feePercentange uint8 Percentage of fee to be deducted which is in the range of 0-100 as integer
     */
    function transferAndChargeByPercentage(address token, address to, uint256 amount, uint8 feePercentage) public payable {
        if (token == address(0)) {
            transferAndChargeByPercentageAsEther(to, msg.value, feePercentage);
        } else {
            transferAndChargeByPercentageAsToken(token, msg.sender, to, amount, feePercentage);
        }
    }

    function transferAndChargeByPercentageAsEther(address to, uint256 amount, uint8 feePercentage) private {
        uint256 feeAmount = amount.mul(feePercentage).div(100);
        transferAndChargeByAmountAsEther(to, amount, feeAmount);
    }

    function transferAndChargeByPercentageAsToken(address token, address from, address to, uint256 amount, uint8 feePercentage) private {
        uint256 feeAmount = amount.mul(feePercentage).div(100);
        transferAndChargeByAmountAsToken(token, from, to, amount, feeAmount);
    }

    function transferAndChargeByAmountAsEther(address to, uint256 amount, uint256 feeAmount) private {
        require(to != address(0), "Recipient address cannot be 0x0!");
        // Transfer the remaining amount after fee deduction to the recipient
        withdrawEther(to, amount.sub(feeAmount));

        emit FeeCollected(address(0), msg.sender, feeAmount);
    }

    function transferAndChargeByAmountAsToken(address token, address from, address to, uint256 amount, uint256 feeAmount) private {
        require(token != address(0), "Token address cannot be 0x0!");
        // Collect fee
        require(ERC20(token).transferFrom(from, address(this), feeAmount), "Cannot transfer fee to the fee collector!");
        // And transfer the remaining amount to the recipient
        require(ERC20(token).transferFrom(from, to, amount.sub(feeAmount)), "Cannot transfer asset to the recipient!");

        emit FeeCollected(token, from, feeAmount);
    }
}