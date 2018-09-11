/**
 * Converts ether to wei
 * 
 * @param {Number} n Ether value to be converted to wei.
 */
function ether(n) {
    return new web3.BigNumber(web3.toWei(n, 'ether'));
}

/**
 * Converts gwei to wei
 * 
 * @param {Number} n Gwei value to be converted to wei.
 */
function gwei(n) {
    return new web3.BigNumber(web3.toWei(n, 'gwei'));
}

// Notice that this approximation does not neccessarily mean that it is correct.
// Therefore do not rely on this approximation all the time
// If there needs fine tuning to check/compare ether balances before and after transactions,
// change this gas limit and fee accordingly!
function defaultTxCost() {
    let gasFee = new web3.BigNumber(web3.toWei(100, 'gwei'));
    let gasLimit = new web3.BigNumber('200000');

    return gasFee.mul(gasLimit);
}

/**
 * Calculates value of the given amount of token in ether.
 * 
 * @param {web3.BigNumber} tokenAmount 
 * @param {web3.BigNumber} tokenPrice Price of token in wei
 * @param {web3.BigNumber} feeRate Fee rate to be applied to the trade
 * @param {boolean} isBuy Type of trade (`true` for buys and `false` for sells)
 */
function calculateCost(tokenAmount, tokenPrice, feeRate, isBuy) {
    let baseCost = tokenAmount.mul(tokenPrice);
    // TODO: Provide fee rate denominator as a parameter
    let feeCost = feeRate > 0 ? baseCost.mul(feeRate).div(10000) : new web3.BigNumber(0);

    return isBuy ? baseCost.add(feeCost) : baseCost.sub(feeCost);
}
  
module.exports = {
    ether,
    gwei,
    defaultTxCost,
    calculateCost
}