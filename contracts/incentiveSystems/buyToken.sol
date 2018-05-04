pragma solidity 0.4.19;

import "../PermissionGroups.sol";


contract buyToken is PermissionGroups {

    mapping (address => uint) public buyToken;
    address[] public buyTokenGroup;                                  
    address[] public buyAirdropGroup;                                 
    address[] public buyExpiredGroup;                            


    function getBuyCount(address _user) external view returns(uint) {
        return buyToken[_user];
    }

    function getBuyGroup() external view returns(address[]) {
        return buyTokenGroup;
    }

    function addBuy(address _initBuyUser) public {
        require(buyToken[_initBuyUser] == 0);                             

        BuyAdded(_initBuyUser, 1);                                 
        buyToken[_initBuyUser] = 1;
        buyTokenGroup.push(_initBuyUser);
    }

    function addBuyAirdrop(address _user) public {
        require(buyToken[_user] < 1001);
        uint cnt = buyToken[_user];

        BuyAirdropUsersAdded(_user, cnt);
        buyAirdropGroup.push(_user);

        buyToken[_user] += 1;                                       
    }

    function addBuyExpiredUsers(address _user) public {
        require(buyToken[_user] > 1000);

        BuyExpiredUsersAdded(_user);
        buyExpiredGroup.push(_user);
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

    event BuyAdded(address newUser, uint count);
    event BuyAirdropUsersAdded(address user, uint count);
    event BuyExpiredUsersAdded(address expiredUser);

}
