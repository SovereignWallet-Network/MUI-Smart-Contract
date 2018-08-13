pragma solidity 0.4.24;

import "./token/ERC20.sol";
import "./token/Withdrawable.sol";
import "./token/Depositable.sol";
import "./lifecycle/Destructible.sol";
import "./lifecycle/Pausable.sol";


/**
 * @title Airdrop
 * @dev Airdropping strategy with Merkle tree proof
 * @notice Be aware of Transaction-Ordering attack(low severity). Assume that 
 * the miner has an address in the wallet in regard (SovereingWallet in our case)
 * and also assume that he picks up `setIncentives()` transaction made by the wallet 
 * from the transaction pool. In this case, the miner can make `claim()` transaction 
 * and prefer to mine his transcation first. And then after the wallet's transcation 
 * is mined he may make `claim()` transaction again to claim the incentivized tokens again. 
 * However the severity of this attack is very low and considering the amount of token
 * dropped per address, the mutliple claimable token amount is negligible. Also all the inputs
 * for public function calls will be provided by centralized server which means that
 * the attacker can never claim with correct inputs by himself.
 */
contract Airdrop is Withdrawable, Depositable, Destructible, Pausable {

    ERC20 public token;
    bytes32 public incentiveRoothash;
    mapping (uint256 => mapping (uint256 => uint256)) public redeemTable;
    uint256 public version = 0;

    event Claimed(address indexed claimer, uint256 amount);


    constructor(ERC20 tokenAddress) public {
        token = ERC20(tokenAddress);
    }

    /**
     * @dev Do not accept direct ether receivals
     */
    function () public payable {
        revert("Direct payments are not accepted!");
    }

    /**
     * @dev Sets the hash root of incentives and unpaused the contract.
     *      The contract should be already paused to be able to call this function.
     * @param _incentiveRoothash bytes32
     */
    function setIncentives(bytes32 _incentiveRoothash) external whenPaused onlyAdmin {
        incentiveRoothash = _incentiveRoothash;
        // Assuming that there won't be hash update as much as uint256 overflows (2**256)
        version++;

        // Unpause claims
        super.unpause();
    }

    /**
     * @dev Checks whether the incentive with the given index is already claimed or not
     * @param index uint256 Index to be checked
     * @return True if it is already claimed, false otherwise
     */
    function isClaimed(uint256 index) public view returns (bool) {
        mapping (uint256 => uint256) redeemed = redeemTable[version];
        uint256 redeemedBlock = redeemed[index / 256];
        uint256 redeemedMask = (uint256(1) << uint256(index % 256));
        return ((redeemedBlock & redeemedMask) != 0);
    }

    /**
     * @dev Claims the incentive and transfer that amount of token to the claimer
     * @param index uint256 Index to be claimed
     * @param amount uint256 Amount of token to be claimed
     * @param merkleProof bytes32[] Merkle Tree Proof for the given input and claimer
     */
    function claim(uint256 index, uint256 amount, bytes32[] merkleProof) external onlyWhiteListed whenNotPaused {
        // Check whether this incentive is already claimed or not
        // If it is so, revert. Otherwise mark it as claimed
        // If the merkle proof does not check, this part will be reverted too.
        markClaimed(index);
        // Check the merkle proof
        require(checkMerkleProof(index, msg.sender, amount, merkleProof), "Merkle proof does not match!");
        // Redeem incentivized tokens
        withdrawToken(token, msg.sender, amount);

        emit Claimed(msg.sender, amount);
    }

    /**
     * @dev Claims the incentive and transfer that amount of token to the claimer
     * @param index uint256 Index to be claimed
     * @param recipient address Claimer's address
     * @param amount uint256 Amount of token to be claimed
     * @param merkleProof bytes32[] Merkle Tree Proof for the given input and claimer
     * @return True if the given inputs check the given merkle proof, false otherwise
     */
    function checkMerkleProof(uint256 index, address recipient, uint256 amount, bytes32[] merkleProof) private view returns (bool) {
        // Compute the hash of the data leaf
        bytes32 node = keccak256(abi.encodePacked(index, recipient, amount));
        uint256 path = index;
        for (uint16 i = 0; i < merkleProof.length; i++) {
            // Compute the hash of the node. Order of hasing is important!
            if ((path & 0x01) == 1) {
                // If the current node is an even node, it must be hashed from right
                node = keccak256(abi.encodePacked(merkleProof[i], node));
            } else {
                // If the current node is an odd node, it must be hashed from left
                node = keccak256(abi.encodePacked(node, merkleProof[i]));
            }
            // Move to upper level in the tree
            path /= 2;
        }

        return node == incentiveRoothash;
    }

    /**
     * @dev Checks whether the incentive with the given index is already claimed or not
     * @dev and marks the incentive as claimed if it is not already claimed.
     * @dev Reverts otherwise
     * @param index uint256 Index to be checked
     */
    function markClaimed(uint256 index) private {
        uint256 redeemedBlock = redeemTable[version][index / 256];
        uint256 redeemedMask = (uint256(1) << uint256(index % 256));
        require((redeemedBlock & redeemedMask) == 0, "Already claimed!");
        redeemTable[version][index / 256] = redeemedBlock | redeemedMask;
    }
}