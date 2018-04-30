pragma solidity 0.4.19;

import "../PermissionGroups.sol";


contract friendRequest is PermissionGroups {
    // @todo change public to internal later (security)

    mapping (address => uint) public friendRequestUsers;
    address[] public friendRequestUsersGroup;                                   // list

    address[] public friendRequestAirdropGroup;                                 // queue
    address[] public friendRequestExpiredGroup;                                 // list


    function getFriendRequestUserCount(address _user) external view returns(uint){
        return friendRequestUsers[_user];
    }

    function getFriendRequestUsersGroup () external view returns(address[]) {
        return friendRequestUsersGroup;
    }

    // add 'friendRequestUsers' to 'friendRequestUsersGroup'
    function addFriendRequestUsers(address _newUser) public {
        require(friendRequestUsers[_newUser] == 0);                             // prevent duplicates

        FriendRequestUsersAdded(_newUser, 1);                                   // count : 1
        friendRequestUsers[_newUser] = 1;
        friendRequestUsersGroup.push(_newUser);
    }

    // add user to 'friendRequestAirdropGroup'
    function addfriendRequestAirdropUsers(address _user) public {
        require(friendRequestUsers[_user] < 6);
        uint cnt = friendRequestUsers[_user];

        FriendRequestAirdropUsersAdded(_user, cnt);
        friendRequestAirdropGroup.push(_user);

        friendRequestUsers[_user] += 1;                                         // increase the count
    }

    // add user to 'friendRequestExpiredGroup' (needed to save in somewhere i.e. firestore)
    function addfriendRequestExpiredUsers(address _user) public {
        require(friendRequestUsers[_user] > 5);

        FriendRequestExpiredUsersAdded(_user);
        friendRequestExpiredGroup.push(_user);
    }

    // TODO FROM HERE!!!
    // remove
    function removeFriendRequestUsers(address _expiredUser) public {
        for (uint i = 0; i < friendRequestUsersGroup.length; ++i) {
            if (friendRequestUsersGroup[i] == _expiredUser) {
                friendRequestUsersGroup[i] = friendRequestUsersGroup[friendRequestUsersGroup.length - 1];
                friendRequestUsersGroup.length -= 1;

                addfriendRequestExpiredUsers(_expiredUser);
                FriendRequestExpiredUsersAdded(_expiredUser);
                break;
            }
        }
    }

    function FriendRequestEvent(address _from, address _to) {
        if(friendRequestUsers[_from] == 0) {
            addFriendRequestUsers(_from);                                       // add user to userlist
            addfriendRequestAirdropUsers(_from);                                // add user to airdrop-userlist
        } else {
            if(friendRequestUsers[_from] < 6) {
                addfriendRequestAirdropUsers(_from);                            // add user to airdrop-userlist
                friendRequestUsers[_from] += 1;                                 // increase the request count
            } else {
                removeFriendRequestUsers(_from);
                // addfriendRequestExpiredUsers(_from);                         // add user to expired-userlist
                // @todo remove the user from friendRequestUsersGroup
            }
        }

        // if(friendRequestUsers[_to] == 0) {
        //     addFriendRequestUsers(_to);
        // } else {
        //     friendRequestUsers[_to] += 1;
        // }
    }

    event FriendRequestUsersAdded(address newUser, uint count);
    event FriendRequestAirdropUsersAdded(address user, uint count);
    event FriendRequestExpiredUsersAdded(address expiredUser);

}
