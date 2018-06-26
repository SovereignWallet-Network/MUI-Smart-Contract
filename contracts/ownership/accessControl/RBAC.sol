pragma solidity ^0.4.23;

import "./Roles.sol";


/**
 * @title RBAC (Role-Based Access Control)
 * @author OpenZeppelin
 * @dev Stores and provides setters and getters for roles and addresses.
 * @dev Supports unlimited numbers of roles and addresses.
 * @dev This RBAC method uses strings to key roles.
 */
contract RBAC {
    using Roles for Roles.Role;

    mapping (string => Roles.Role) private roles;

    event RoleAdded(address indexed addr, string roleName);
    event RoleRemoved(address indexed addr, string roleName);

    /**
     * @dev reverts if addr does not have role
     * @param addr address
     * @param roleName the name of the role
     * // reverts
     */
    function checkRole(address addr, string roleName) view public {
        roles[roleName].check(addr);
    }

    /**
     * @dev determine if addr has role
     * @param addr address
     * @param roleName the name of the role
     * @return bool
     */
    function hasRole(address addr, string roleName) view public returns (bool) {
        return roles[roleName].has(addr);
    }

    /**
     * @dev add a role to an address
     * @param addr address
     * @param roleName the name of the role
     */
    function addRole(address addr, string roleName) internal {
        roles[roleName].add(addr);
        emit RoleAdded(addr, roleName);
    }

    /**
     * @dev remove a role from an address
     * @param addr address
     * @param roleName the name of the role
     */
    function removeRole(address addr, string roleName) internal {
        roles[roleName].remove(addr);
        emit RoleRemoved(addr, roleName);
    }

    /**
     * @dev modifier to scope access to a single role (uses msg.sender as addr)
     * @param roleName the name of the role
     * // reverts
     */
    modifier onlyRole(string roleName) {
        checkRole(msg.sender, roleName);
        _;
    }
}
