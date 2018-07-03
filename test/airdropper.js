const web3Utils = require('web3-utils');


function AirDropper(balances) {
    if (!(this instanceof AirDropper)) { 
        throw new Error('missing new');
    }

    this.balances = balances;
    this.rootHash = computeRootHash(balances);
}

AirDropper.prototype.updateRootHash = function(balances) {
    this.balances = balances;
    this.rootHash = computeRootHash(balances);
}

AirDropper.prototype.getRootHash = function() {
    return this.rootHash;
}

AirDropper.prototype.getIndex = function(address) {
    address = address.toLowerCase();

    var leaves = expandLeaves(this.balances);

    var index = null;
    for (var i = 0; i < leaves.length; i++) {
        if (i != leaves[i].index) { 
            throw new Error('Fatal: Index data and index of the address in the data array do not match!'); 
        }
        if (leaves[i].address === address) { 
            return leaves[i].index; 
        }
    }

    throw new Error('address not found');
}

AirDropper.prototype.getAddress = function(index) {
    var leaves = expandLeaves(this.balances);
    return leaves[index].address;
}

AirDropper.prototype.getAmount = function(index) {
    var leaves = expandLeaves(this.balances);
    return leaves[index].balance;
}

AirDropper.prototype.getMerkleProof = function(index) {
    return computeMerkleProof(this.balances, index);
}

AirDropper.prototype.checkMerkleProof = function(index, recipient, amount, merkleProof) {
    // Compute the hash of the data leaf
    let node = web3Utils.soliditySha3(index, recipient, amount)
    
    let path = index;
    for (let i = 0; i < merkleProof.length; i++) {
        
        // Compute the hash of the node. Order of hasing is important!
        if ((path & 1) == 1) {
            // If the current node is an even node, it must be hashed from right
            node = web3Utils.soliditySha3(merkleProof[i], node);
        } else {
            // If the current node is an odd node, it must be hashed from left
            node = web3Utils.soliditySha3(node, merkleProof[i]);
        }
        // Move to upper level in the tree
        path /= 2;
    }

    return node == this.rootHash;
}


/******************* Pure functions *******************/

/**
 * Creates an formatted/ordered data-set from the given data-set
 * 
 * @param {Array} balances Data-set to be formatted
 * @returns {Array} Formatted/Ordered data-set
 */
function expandLeaves(balances) {
    var addresses = Object.keys(balances);

    // This sorting totally depends on the choice of developer on backend
    // However if you decide to apply any kind of sorting, the index data
    // for all other functions should be provided in the same way as it is
    // implemented here

    // addresses.sort(function(a, b) {
    //     var al = a.toLowerCase(), bl = b.toLowerCase();
    //     if (al < bl) { return -1; }
    //     if (al > bl) { return 1; }
    //     return 0;
    // });

    return addresses.map(function(a, i) {return { address: a, balance: balances[a], index: i }; });
}

/**
 * Calculates the hash of each tree in the given data-set
 * 
 * @param {Array} balances Data-set to be hashed
 * @returns {Array} Array of hashed data-set
 */
function getLeaves(balances) {
    var leaves = expandLeaves(balances);
    return leaves.map(function(leaf) {
        return web3Utils.soliditySha3(leaf.index, leaf.address, leaf.balance);
    });
}

/**
 * Reduces Merkle Tree one level
 * 
 * @param {Array} leaves Leaves of the to be reduced one level
 */
function reduceMerkleBranches(leaves) {
    var output = [];
    let x = 0;
    while (leaves.length) {
        var left = leaves.shift();
        var right = (leaves.length === 0) ? left: leaves.shift();
        output.push(web3Utils.soliditySha3(left, right));
    }

    output.forEach(function(leaf) {
        leaves.push(leaf);
    });
}

/**
 * Calculates the root hash of the given data-set
 * according to Merkle Tree
 * @param {Array} balances `[{address: balance},...]` Array of data to be hash-proofed
 */
function computeRootHash(balances) {
    var leaves = getLeaves(balances);

    while (leaves.length > 1) {
        reduceMerkleBranches(leaves);
    }
    return leaves[0];
}

/**
 * Calculates the merkle tree proof for the given index
 * from the given balances array.
 * @param {Array} balances `[{address: balance},...]` Array of data to be hash-proofed
 * @param {Number} index Index of the data to be looked for
 * @returns {Byte32String} Merkle tree proof
 */
function computeMerkleProof(balances, index) {
    let leaves = getLeaves(balances);

    if (index == null) { 
        throw new Error('address not found'); 
    }

    let path = index;
    let nextNode;
    let proof = [];
    while (leaves.length > 1) {
        // If the index is odd, take node before the current node
        // otherwise, take the node after the current node
        nextNode = (path % 2) == 1 
                ? leaves[path - 1] 
                : leaves[path + 1];

        // Check whether the next node is available or not
        // If it does not exit (which means that the number of
        // nodes in the current tree level is odd and the last
        // node should be hashed with itself), just push the
        // current node to the proof array. 
        // Otherwise, just use the next node.
        if (nextNode === undefined || nextNode == null) {
            proof.push(leaves[path]);
        } else {
            proof.push(nextNode);
        }
        
        // Reduce the merkle tree one level
        reduceMerkleBranches(leaves);

        // Move up
        path = parseInt(path / 2);
    }
    return proof;
}


module.exports = AirDropper;
