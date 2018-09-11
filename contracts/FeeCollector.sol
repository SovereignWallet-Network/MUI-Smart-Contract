pragma solidity 0.4.24;

import "./utils/SafeMath.sol";
import "./token/ERC20.sol";
import "./token/Withdrawable.sol";
import "./lifecycle/Destructible.sol";
import "./lifecycle/Pausable.sol";


/**
 * @dev FeeCollector contract which helps us to collect fee
 *      from any kind of asset transfers from our SovereignWallet App.
 *
 * @notice In token transfers, the user must have already approve some token 
 *         allownace in advance, otherwise the transaction will be reverted.
 * @notice Fee can be set as a fixed amount in wei or as percentage of the
 *         asset in regard.
 */
contract FeeCollector is Withdrawable, Destructible, Pausable {
    using SafeMath for uint256;

    event FeeCollected(address indexed feeAsset, address indexed from, uint256 feeAmount);

    uint256 public fee = 0;                      // Fixed amount of fee in wei
    uint256 public feeRatio = 0;                 // Dividend of the fee ratio
    uint256 public feeRatioDenominator = 100;    // Denominator of the fee ratio


    /**
     * @dev Initializes fee and fee ration at the deployment time
     */
    constructor(uint256 _fee, uint256 _feeRatio, uint256 _feeRatioDenominator) public payable {
        fee = _fee;
        setFeeRatio(_feeRatio, _feeRatioDenominator);
    }

    function () public payable {
        revert("Direct ether receivals are not allowed!");
    }

    /**
     * @param _fee uint256 Fee value in wei to be set
     */
    function setFee(uint256 _fee) public onlyAdmin {
        fee = _fee;
    }

    /**
     * @param _feeRatio uint256 Dividend of fee ratio
     * @param _feeRatioDenominator uint256 Denominator of fee ratio
     */
    function setFeeRatio(uint256 _feeRatio, uint256 _feeRatioDenominator) public onlyAdmin {
        require(_feeRatioDenominator > 0, "Denominator of fee ratio must be greater than zero!");
        require(_feeRatioDenominator >= _feeRatio, "Dividend of fee ratio cannot be greater than its denominator!");
        feeRatio = _feeRatio;
        feeRatioDenominator = _feeRatioDenominator;
    }

    /**
     * @dev Expects the fee to be sent alongside with the transcation in ether. In case of token transfers,
     *      the ether amount sent alongside with the transaction is taken as fee and it should be equal to
     *      or greater than the fee amount. Otherwise the transaction will be reverted. In case of ether transfers,
     *      token address should be passed as 0x0 and amount parameter will be ignored. 
     * @param token address Address of the ERC20 token to be transferred. Pass as 0x0 in case of ether transfers
     * @param to address Address of the recipient
     * @param amount uint256 Amount of the incoming transfer. Ignored in case of ether transfers
     */
    function transferAndChargeByFee(address token, address to, uint256 amount) public payable onlyWhiteListed {
        require(msg.value >= fee, "Ether amount is not enough for fee payment!");

        if (token == address(0)) {
            transferAndChargeByEther(to, msg.value, fee);
        } else {
            require(ERC20(token).transferFrom(msg.sender, to, amount), "Cannot transfer asset to the recipient!");
            emit FeeCollected(token, msg.sender, fee);
        }
    }

    /**
     * @dev Deducts the provided percent of fee (in the same asset as the transferred one)
     *      from the total amount given. In case of ether transfers, token address should
     *      be passed as 0x0 and amount parameter will be ignored. The ether amount sent
     *      alongside with the transaction should be greater than the fee amount
     *      calculated by the percent. Otherwise transaction will be reverted.
     * @param token address Address of the ERC20 token to be transferred. Pass 0x0 in case of ether transfers
     * @param to address Address of the recipient
     * @param amount uint256 Amount of the incoming transfer. Ignored in case of ether transfers
     */
    function transferAndChargeByFeeRatio(address token, address to, uint256 amount) public payable onlyWhiteListed {
        if (token == address(0)) {
            transferAndChargeByEther(to, msg.value, calculateFeeFromRatio(msg.value));
        } else {
            transferAndChargeByToken(token, msg.sender, to, amount, calculateFeeFromRatio(amount));
        }
    }

    function transferAndChargeByEther(address to, uint256 amount, uint256 feeAmount) private {
        require(to != address(0), "Recipient address cannot be 0x0!");
        // Transfer the remaining amount after fee deduction to the recipient
        withdrawEther(to, amount.sub(feeAmount));

        emit FeeCollected(address(0), msg.sender, feeAmount);
    }

    function transferAndChargeByToken(address token, address from, address to, uint256 amount, uint256 feeAmount) private {
        require(token != address(0), "Token address cannot be 0x0!");
        // Collect fee
        require(ERC20(token).transferFrom(from, address(this), feeAmount), "Cannot transfer fee to the fee collector!");
        // And transfer the remaining amount to the recipient
        require(ERC20(token).transferFrom(from, to, amount.sub(feeAmount)), "Cannot transfer asset to the recipient!");

        emit FeeCollected(token, from, feeAmount);
    }

    /**
     * @notice Assuming that `feeRatioDenominator` will not result in
     *         a floating point return value.
     */
    function calculateFeeFromRatio(uint256 amount) private view returns(uint256) {
        return amount.div(feeRatioDenominator).mul(feeRatio);
    }
}
