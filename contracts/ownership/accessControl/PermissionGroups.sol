pragma solidity ^0.4.23;


import "./RBAC.sol";
import "../../utils/PositiveMath.sol";


/**
 * @title PermissonGroups
 * @dev Handles permisson management
 * @dev Admins are the ultimate decision makers.
 * @dev Therefore there should be always one admin, otherwise
 * @dev this contract will fall into uncontrolled state.
 */
contract PermissionGroups is RBAC {
    using PositiveMath for uint256;

    string public constant ROLE_ADMIN = "admin";
    string public constant ROLE_OPERATOR = "operator";
    uint256 private constant MAX_ADMIN_SIZE = 5;
    uint256 private constant MAX_OPERATOR_SIZE = 50;

    uint256 private adminSize = 0;
    uint256 private operatorSize = 0;

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
     * @dev constructor. Sets msg.sender as admin by default
     */
    constructor() public {
        adminSize.increment();
        addRole(msg.sender, ROLE_ADMIN);
    }

    /**
     * @dev Adds admin role to an address
     * @param newAdmin address
     */
    function addAdmin(address newAdmin) public onlyAdmin {
        require(adminSize < MAX_ADMIN_SIZE);
        require(newAdmin != address(0));

        adminSize.increment();
        addRole(newAdmin, ROLE_ADMIN);
    }

    /**
     * @dev Removes admin role from an address
     * @param admin address
     */
    function removeAdmin(address admin) public onlyAdmin {
        // Removing all admins will put 
        // the permisson groups in uncontrolled state
        require(adminSize > 1);
        
        adminSize.decrement();
        removeRole(admin, ROLE_ADMIN);
    }

    /**
     * @dev Checks whether the address has operator role
     * @param addr address
     */
    function isAdmin(address addr) external view returns(bool) {
        return hasRole(addr, ROLE_ADMIN);
    }

    /**
     * @dev Returns size of the admin group
     */
    function getSizeOfAdmins() external view returns(uint256) {
        return adminSize;
    }

    /**
     * @dev Adds operator role to an address
     * @param newOperator address
     */
    function addOperator(address newOperator) public onlyAdmin {
        require(operatorSize < MAX_OPERATOR_SIZE);
        require(newOperator != address(0));

        operatorSize.increment();
        addRole(newOperator, ROLE_OPERATOR);
    }

    /**
     * @dev Removes operator role from an address
     * @param operator address
     */
    function removeOperator(address operator) public onlyAdmin {
        operatorSize.decrement();
        removeRole(operator, ROLE_OPERATOR);
    }

    /**
     * @dev Checks whether the address has operator role
     * @param addr address
     */
    function isOperator(address addr) external view returns(bool) {
        return hasRole(addr, ROLE_OPERATOR);
    }

    /**
     * @dev Returns size of the operator group
     */
    function getSizeOfOperators() external view returns(uint256) {
        return operatorSize;
    }
}
