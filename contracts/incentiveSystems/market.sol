pragma solidity 0.4.19;

import "../PermissionGroups.sol";


contract market is PermissionGroups {

    mapping (address => uint) public buyToken;
    mapping (address => uint) public sellToken;
    address[] public buyTokenGroup;
    address[] public sellTokenGroup;                                   
    address[] public buyAirdropGroup;
    address[] public sellAirdropGroup;                                 
    address[] public buyExpiredGroup;
    address[] public sellExpiredGroup;                                


    function getBuyCount(address _user) external view returns(uint) {
        return buyToken[_user];
    }

    function getSellCount(address _user) external view returns(uint) {
        return sellToken[_user];
    }

    function getBuyGroup() external view returns(address[]) {
        return buyTokenGroup;
    }

    function getSellGroup() external view returns(address[]) {
        return sellTokenGroup;
    }

    function addBuy(address _initBuyUser) public {
        require(buyToken[_initBuyUser] == 0);                             

        BuyAdded(_initBuyUser, 1);                                 
        buyToken[_initBuyUser] = 1;
        buyTokenGroup.push(_initBuyUser);
    }

    function addSell(address _initSellUser) public {
        require(sellToken[_initSellUser] == 0);                             

        SellAdded(_initSellUser, 1);                                 
        sellToken[_initSellUser] = 1;
        sellTokenGroup.push(_initSellUser);
    }

    function addBuyAirdrop(address _user) public {
        require(buyToken[_user] < 1001);
        uint cnt = buyToken[_user];

        BuyAirdropUsersAdded(_user, cnt);
        buyAirdropGroup.push(_user);

        buyToken[_user] += 1;                                       
    }

    function addSellAirdrop(address _user) public {
        require(sellToken[_user] < 1001);
        uint cnt = sellToken[_user];

        SellAirdropUsersAdded(_user, cnt);
        sellAirdropGroup.push(_user);

        sellToken[_user] += 1;                                       
    }

    function addBuyExpiredUsers(address _user) public {
        require(buyToken[_user] > 1000);

        BuyExpiredUsersAdded(_user);
        buyExpiredGroup.push(_user);
    }

    function addSellExpiredUsers(address _user) public {
        require(sellToken[_user] > 1000);

        SellExpiredUsersAdded(_user);
        sellExpiredGroup.push(_user);
    }

    function buyEvent(address _from) {
        if (buyToken[_from] == 0) {
            addBuy(_from);
            addBuyAirdrop(_from);                                                                                
        } else if (buyToken[_from] < 1001) {
            require(buyToken[_from] > 0);  
            addBuyAirdrop(_from); 
            buyToken[_from] += 1;                                                           
        } else {
            addBuyExpiredUsers(_from);
        }
    }

    function sellEvent(address _from) {
        if (sellToken[_from] == 0) {
            addSell(_from);
            addSellAirdrop(_from);                                                                                
        } else if (sellToken[_from] < 1001) {
            require(sellToken[_from] > 0);  
            addSellAirdrop(_from); 
            sellToken[_from] += 1;                                                           
        } else {
            addSellExpiredUsers(_from);
        }
    }

    event BuyAdded(address newUser, uint count);
    event SellAdded(address newUser, uint count);
    event BuyAirdropUsersAdded(address user, uint count);
    event SellAirdropUsersAdded(address user, uint count);
    event BuyExpiredUsersAdded(address expiredUser);
    event SellExpiredUsersAdded(address expiredUser);

}
