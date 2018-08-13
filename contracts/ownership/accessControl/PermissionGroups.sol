pragma solidity 0.4.24;


import "./RBAC.sol";
import "../../utils/SafeMath.sol";


/**
 * @title PermissonGroups
 * @dev Handles permisson management
 * @dev Admins are the ultimate decision makers.
 * @dev Therefore there should be always one admin, otherwise
 * @dev this contract will fall into an uncontrolled state.
 */
contract PermissionGroups is RBAC {
    using SafeMath for uint256;

    string public constant ROLE_ADMIN = "admin";
    string public constant ROLE_OPERATOR = "operator";
    string public constant ROLE_BLACK_LISTED = "blacklisted";
    uint256 public constant MAX_ADMIN_SIZE = 5;
    uint256 public constant MAX_OPERATOR_SIZE = 50;

    uint256 public adminSize = 0;
    uint256 public operatorSize = 0;

    /**
     * @dev modifier to scope access to admins
     * // reverts
     */
    modifier onlyAdmin() {
        checkRole(msg.sender, ROLE_ADMIN);
        _;
    }

    /**
     * @dev modifier to scope access to operators
     * // reverts
     */
    modifier onlyOperator() {
        checkRole(msg.sender, ROLE_OPERATOR);
        _;
    }

    /**
     * @dev modifier to scope denial for blacklisted addresses
     * // reverts
     */
    modifier onlyWhiteListed() {
        require(!hasRole(msg.sender, ROLE_BLACK_LISTED));
        _;
    }

    /**
     * @dev constructor. Sets msg.sender as admin by default
     */
    constructor() public {
        adminSize = adminSize.add(1);
        addRole(msg.sender, ROLE_ADMIN);
    }

    /**
     * @dev Adds admin role to an address
     * @param newAdmin address
     */
    function addAdmin(address newAdmin) public onlyAdmin {
        require(adminSize < MAX_ADMIN_SIZE);
        require(newAdmin != address(0));

        require(!isAdmin(newAdmin));
        adminSize = adminSize.add(1);
        
        addRole(newAdmin, ROLE_ADMIN);
    }

    /**
     * @dev Removes admin role from an address
     * @param admin address
     */
    function removeAdmin(address admin) public onlyAdmin {
        // Removing all admins will put 
        // the permisson groups in an uncontrolled state
        require(adminSize > 1);
        
        adminSize = adminSize.sub(1);
        removeRole(admin, ROLE_ADMIN);
    }

    /**
     * @dev Checks whether the address has operator role
     * @param addr address
     */
    function isAdmin(address addr) public view returns(bool) {
        return hasRole(addr, ROLE_ADMIN);
    }

    /**
     * @dev Adds operator role to an address
     * @param newOperator address
     */
    function addOperator(address newOperator) public onlyAdmin {
        require(operatorSize < MAX_OPERATOR_SIZE);
        require(newOperator != address(0));

        require(!isOperator(newOperator));
        operatorSize = operatorSize.add(1);

        addRole(newOperator, ROLE_OPERATOR);
    }

    /**
     * @dev Removes operator role from an address
     * @param operator address
     */
    function removeOperator(address operator) public onlyAdmin {
        operatorSize = operatorSize.sub(1);
        removeRole(operator, ROLE_OPERATOR);
    }

    /**
     * @dev Checks whether the address has operator role
     * @param addr address
     */
    function isOperator(address addr) public view returns(bool) {
        return hasRole(addr, ROLE_OPERATOR);
    }

    /**
     * @dev Adds blacklisted role to an address
     * @param blackListed address
     */
    function addToBlackList(address blackListed) public onlyAdmin {
        require(blackListed != address(0));
        addRole(blackListed, ROLE_BLACK_LISTED);
    }

    /**
     * @dev Removes blacklisted role from an address
     * @param blackListed address
     */
    function removeFromBlackList(address blackListed) public onlyAdmin {
        removeRole(blackListed, ROLE_BLACK_LISTED);
    }

    /**
     * @dev Checks whether the address has blacklisted role
     * @param addr address
     */
    function isBlackListed(address addr) public view returns(bool) {
        return hasRole(addr, ROLE_BLACK_LISTED);
    }
}
