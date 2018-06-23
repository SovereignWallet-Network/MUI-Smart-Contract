pragma solidity ^0.4.23;

import "./token/ERC20.sol";
import "./utils/SafeMath.sol";
import "./token/Withdrawable.sol";
import "./token/Depositable.sol";
import "./lifecycle/Destructible.sol";


/**
 * @author Mustafa Morca
 * @title ACB
 * @dev Algorithmic Central Bank
 */
contract ACB is Withdrawable, Depositable, Destructible {
    using SafeMath for uint256;

    uint256 public constant FEE_RATE_DENOMINATOR = 1000000;

    ERC20 public token;
    uint256 public buyPriceACB;     // Price of the 1 token in wei
    uint256 public sellPriceACB;    // Price of 1 ether in token
    uint256 public buySupplyACB = 0;
    uint256 public sellSupplyACB = 0;
    uint256 public feeRateACB = 0;
    uint256 public minSellAmountACB = 0;
    uint256 public maxBuyAmountACB = ~uint256(0);


    event TokenExchange(address indexed client, uint256 tokenAmount, uint256 atPrice, bool isBuy);
    

    /**
     * @notice Do not accept direct ether receivals
     */
    function() public payable {
        revert();
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
        public payable 
    {
        token = ERC20(tokenAddress);
        setPrices(initialBuyPrice, initialSellPrice);
    }

    /**
     * @dev Sets the prices in ACB for trade.
     * @notice Does not allow to set prices zero 
     * but also does not revert to keep the previous values.
     * @param _buyPriceACB uint256 The price that ACB buys the token in regard
     * @param _sellPriceACB uint 256 The price that ACB sells the token in regard
     */
    function setPrices(uint256 _buyPriceACB, uint256 _sellPriceACB) public onlyAdmin {
        if (_buyPriceACB > 0) {
            buyPriceACB = _buyPriceACB;

            // Set buySupply too if the buyPrice changes, because depending on the price
            // the contract may not afford to buy all the previous amount of buy supply.
            uint256 newBuySupply = address(this).balance.div(buyPriceACB);
            setSupplies(newBuySupply < buySupplyACB ? newBuySupply : buySupplyACB, sellSupplyACB);
        }

        if (_sellPriceACB > 0) {
            sellPriceACB = _sellPriceACB;
        }
    }

    /**
     * @dev Sets fee rate for ACB services
     * @param feeRate uint256 Desired rate of fee
     */
    function setFeeRate(uint256 feeRate) public onlyAdmin {
        feeRateACB = feeRate;
    }

    /**
     * @dev Sets the available token supplies that ACB can buy and sell
     * @notice If the buy price is zero, it will revert the transaction.
     * @notice Supplies can be set to zero but not to negative values
     * @param _buySupplyACB uint256 Available token supply that ACB can buy
     * @param _sellSupplyACB uint256 Available token supply that ACB can sell
     */
    function setAvailableSupplies(uint256 _buySupplyACB, uint256 _sellSupplyACB) public onlyAdmin {
        // Sell supply shouldn't be more than available token balance of this contract
        require(token.balanceOf(this) >= _sellSupplyACB);
        // Buy supply shouldn't be more than (ether balance / buyPrice) in order to afford to buy
        require(address(this).balance.div(buyPriceACB) >= _buySupplyACB);

        setSupplies(_buySupplyACB, _sellSupplyACB);
    }

    /**
     * @dev Sets the minimum token amount that one can buy from ACB
     * @dev and the maximum token amount one can sell to ACB.
     * @dev If the parameters are passed as zero, it will not set the regarding variable
     * @dev This is for being able to set one variable and to leave the other unchanged
     * @param buyCapACB uit256 Maximum amount of token that can be sold to ACB
     * @param sellCapACB uint256 Minimum amount of token that can be bought from ACB
     */
    function setBuySellCaps(uint256 buyCapACB, uint256 sellCapACB) public onlyAdmin {
        if (buyCapACB > 0) {
            maxBuyAmountACB = buyCapACB;
        }
        
        if (sellCapACB > 0) {
            minSellAmountACB = sellCapACB;
        }
    }

    /**
     * @dev Client (msg.sender) buys token from ACB
     * @notice msg.sender is the buyer's address and msg.value is
     * the total amount of ether in wei that the buyer uses to buy tokens.
     * @notice msg.value should be precisely calculated prior to calling 
     * this function in front-end because there will be no refund to the callee 
     * for the remaing ether sent along this function call.
     * @notice this design may change in future updates.
     */
    function buyFromACB() public payable {
        // Check the minimum cap
        require(msg.value >= minSellAmountACB);
        
        // Calculate the equivalent number of token for the sent ether
        uint256 tokenAmount = sellPriceACB.mul(msg.value).div(1 ether);

        require(sellSupplyACB >= tokenAmount);
        require(token.balanceOf(this) >= tokenAmount);

        sellSupplyACB = sellSupplyACB.sub(tokenAmount);

        // Transfer the requested amount of token to the client
        withdrawToken(token, msg.sender, tokenAmount);
        emit TokenExchange(msg.sender, tokenAmount, sellPriceACB, true);
    }

    /**
     * @dev Client sells (msg.sender) token to ACB
     * @notice Before calling this function in front-end, first approve the amount
     * of token to be sold through MuiToken contract. After the call to `approve()`
     * is mined, call this function.
     * @param tokenAmount uint256 Amount of the token that ACB buys from the seller
     */
    function sellToACB(uint256 tokenAmount) public {
        require(tokenAmount > 0 && tokenAmount <= maxBuyAmountACB);
        require(buySupplyACB >= tokenAmount);

        uint256 weiAmount = calculateCost(tokenAmount, buyPriceACB, feeRateACB, false);

        require(address(this).balance >= weiAmount);

        buySupplyACB = buySupplyACB.sub(tokenAmount);
        // Transfer tokens from seller to ACB contract first
        depositToken(token, msg.sender, tokenAmount);
        // And then, in exchange, send ether to the seller
        withdrawEther(msg.sender, weiAmount);

        emit TokenExchange(msg.sender, tokenAmount, buyPriceACB, false);
    }

    /**
     */
     // TODO: Confirm this function
    function feeCollector(address to, uint256 fee) public payable {
        uint256 afterFee = msg.value.sub(fee);
        to.transfer(afterFee);
    }

    /**
     * @dev Sets the token supplies that ACB can buy and sell
     * @param _buySupplyACB uint256 Available token supply that ACB can buy
     * @param _sellSupplyACB uint256 Available token supply that ACB can sell
     */
    function setSupplies(uint256 _buySupplyACB, uint256 _sellSupplyACB) internal {
        sellSupplyACB = _sellSupplyACB;
        buySupplyACB = _buySupplyACB;
    }

    /**
     * @dev Calculates the cost of the given amount of token in ether(wei)
     * @param tokenAmount uint256 Amount of token whose cost to be calculated
     * @param tokenPrice uint256 Price of token in wei
     * @param feeRate uint256 Rate of fee to be added to the total cost
     * @param isBuy bool Indicates whether the trade is a buy or sell in client's point of view
     * @return Calculated cost
     */
     // TODO: Fee should be taken in token when the client sells tokens to ACB
    function calculateCost(uint256 tokenAmount, uint256 tokenPrice, uint256 feeRate, bool isBuy) internal pure returns(uint256) {
        uint256 baseCost = tokenAmount.mul(tokenPrice);
        uint256 feeCost = feeRate > 0 ? baseCost.mul(feeRate).div(FEE_RATE_DENOMINATOR) : 0;

        return isBuy ? baseCost.add(feeCost) : baseCost.sub(feeCost);
    }
}
