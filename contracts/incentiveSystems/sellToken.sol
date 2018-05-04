pragma solidity 0.4.19;

import "../PermissionGroups.sol";


contract sellToken is PermissionGroups {

    mapping (address => uint) public sellToken;
    address[] public sellTokenGroup;                                   
    address[] public sellAirdropGroup;                                 
    address[] public sellExpiredGroup;                                


    function getSellCount(address _user) external view returns(uint) {
        return sellToken[_user];
    }

    function getSellGroup() external view returns(address[]) {
        return sellTokenGroup;
    }

    function addSell(address _initSellUser) public {
        require(sellToken[_initSellUser] == 0);                             

        SellAdded(_initSellUser, 1);                                 
        sellToken[_initSellUser] = 1;
        sellTokenGroup.push(_initSellUser);
    }

    function addSellAirdrop(address _user) public {
        require(sellToken[_user] < 1001);
        uint cnt = sellToken[_user];

        SellAirdropUsersAdded(_user, cnt);
        sellAirdropGroup.push(_user);

        sellToken[_user] += 1;                                       
    }

    function addSellExpiredUsers(address _user) public {
        require(sellToken[_user] > 1000);

        SellExpiredUsersAdded(_user);
        sellExpiredGroup.push(_user);
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

    event SellAdded(address newUser, uint count);
    event SellAirdropUsersAdded(address user, uint count);
    event SellExpiredUsersAdded(address expiredUser);

}
