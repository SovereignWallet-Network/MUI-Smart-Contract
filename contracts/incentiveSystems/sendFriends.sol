pragma solidity 0.4.19;


import "../PermissionGroups.sol";

contract sendFriends is PermissionGroups {

    mapping (address => uint) public sendFriends;
    address[] public sendFriendGroup;                                   
    address[] public sendFriendAirdropGroup;                                 
    address[] public sendFriendExpiredGroup;                                


    function getSendFriendsCount(address _user) external view returns(uint) {
        return sendFriends[_user];
    }

    function getSendFriendsGroup() external view returns(address[]) {
        return sendFriendGroup;
    }

    function addSendFriends(address _newUser) public {
        require(sendFriends[_newUser] == 0);                             

        SendFriendsAdded(_newUser, 1);                                 
        sendFriends[_newUser] = 1;
        sendFriendGroup.push(_newUser);
    }

    function addSendFriendsAirdrop(address _user) public {
        require(sendFriends[_user] < 101);
        uint cnt = sendFriends[_user];

        SendFriendsAirdropUsersAdded(_user, cnt);
        sendFriendAirdropGroup.push(_user);

        sendFriends[_user] += 1;                                       
    }

    function addSendFriendsExpiredUsers(address _user) public {
        require(sendFriends[_user] > 100);

        SendFriendsExpiredUsersAdded(_user);
        sendFriendExpiredGroup.push(_user);
    }

    function sendFriendsEvent(address _from, address _to) {
        if (sendFriends[_from] == 0) {
            addSendFriends(_from);
            addSendFriendsAirdrop(_from);
            addSendFriends(_to);
            addSendFriendsAirdrop(_to);                                                                                   
        } else if (sendFriends[_from] < 101) {
            require(sendFriends[_from] > 0);  
            addSendFriendsAirdrop(_from);
            addSendFriendsAirdrop(_to);    
            sendFriends[_from] += 1;                                                           
            sendFriends[_to] += 1;
        } else {
            addSendFriendsExpiredUsers(_from);
            addSendFriendsExpiredUsers(_to);
        }
    }

    event SendFriendsAdded(address newUser, uint count);
    event SendFriendsAirdropUsersAdded(address user, uint count);
    event SendFriendsExpiredUsersAdded(address expiredUser);

}
