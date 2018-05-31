
function ether(n) {
    return new web3.BigNumber(web3.toWei(n, 'ether'));
}

function calculateCost(tokenAmount, tokenPrice, feeRate) {
    let baseCost = tokenAmount * tokenPrice;
    let feeCost = feeRate > 0 ? (baseCost / feeRate) : 0;

    return new web3.BigNumber(baseCost + feeCost);
}
  
module.exports = {
    ether: ether,
    calculateCost: calculateCost
}