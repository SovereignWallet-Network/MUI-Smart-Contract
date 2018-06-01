pragma solidity ^0.4.23;

import "./token/ERC20.sol";
import "./token/Withdrawable.sol";
import "./token/Depositable.sol";
import "./lifecycle/Destructible.sol";


/**
 * @title Airdrop
 * @dev Airdropping strategy with Merkle tree proof
 * @notice Be aware of Transaction-Ordering attack(low severity). Assume that 
 * the miner has an address in the wallet in regard (SovereingWallet in our case)
 * and also assume that he picks up `setIncentives()` transaction made by the wallet 
 * from the transaction pool. In this case, the miner can make `claim()` transaction 
 * and prefer to mine his transcation first. And then after the wallet's transcation 
 * is mined he can make `claim()` transaction again to claim incentivized tokens. 
 * However the severity of this attack is very low and considering the amount of token
 * dropped per address, the mutliple claimable token amount is negligible. 
 */
contract Airdrop is Withdrawable, Depositable, Destructible {

    ERC20 public token;
    bytes32 rootHashIncentives;
    mapping (uint256 => uint256) redeemed;


    constructor(ERC20 tokenAddress) public {
        token = ERC20(tokenAddress);
    }

    /**
     * @dev Do not accept direct ether receivals
     */
    function () public payable {
        revert();
    }

    function setIncentives(bytes32 _rootHashIncentives) public onlyAdmin {
        rootHashIncentives = _rootHashIncentives;
    }

    function isClaimed(uint256 index) public view returns (bool) {
        uint256 redeemedBlock = redeemed[index / 256];
        uint256 redeemedMask = (uint256(1) << uint256(index % 256));
        return ((redeemedBlock & redeemedMask) != 0);
    }

    function claim(uint256 index, address recipient, uint256 amount, bytes32[] merkleProof) external {
        // Check whether this incentive is already claimed or not
        markClaimed(index);
        // Check the merkle proof
        require(checkMerkleProof(index, recipient, amount, merkleProof));
        // Redeem incentivized tokens
        withdrawToken(token, recipient, amount);
    }

    function checkMerkleProof(uint256 index, address recipient, uint256 amount, bytes32[] merkleProof) private view returns (bool) {
        // Compute the hash of the data leaf
        bytes32 node = keccak256(index, recipient, amount);
        uint256 path = index;
        for (uint16 i = 0; i < merkleProof.length; i++) {
            // Compute the hash of the node. Order of hasing is important!
            if ((path & 0x01) == 1) {
                // If the current node is an even node, it must be hashed from right
                node = keccak256(merkleProof[i], node);
            } else {
                // If the current node is an odd node, it must be hashed from left
                node = keccak256(node, merkleProof[i]);
            }
            // Move to upper level in the tree
            path /= 2;
        }

        return node == rootHashIncentives;
    }

    function markClaimed(uint256 index) private {
        uint256 redeemedBlock = redeemed[index / 256];
        uint256 redeemedMask = (uint256(1) << uint256(index % 256));
        require((redeemedBlock & redeemedMask) == 0);
        redeemed[index / 256] = redeemedBlock | redeemedMask;
    }
}