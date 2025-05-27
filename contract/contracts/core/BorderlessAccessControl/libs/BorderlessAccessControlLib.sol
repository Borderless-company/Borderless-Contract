// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage as ACStorage} from "../storages/Storage.sol";

// lib
import {Constants} from "../../lib/Constants.sol";

// OpenZeppelin
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

/**
 * @title BorderlessAccessControlLib
 * @notice BorderlessAccessControlLib is a library that provides functions for managing roles and permissions for the Borderless protocol.
 */
library BorderlessAccessControlLib {
    // ============================================== //
    //             INTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    function grantRole(bytes32 role, address account) internal returns (bool) {
        if (!hasRole(role, account)) {
            ACStorage.AccessControlSlot().roles[role].hasRole[account] = true;
            emit IAccessControl.RoleGranted(role, account, msg.sender);
            return true;
        } else {
            return false;
        }
    }

    function revokeRole(bytes32 role, address account) internal returns (bool) {
        if (hasRole(role, account)) {
            ACStorage.AccessControlSlot().roles[role].hasRole[account] = false;
            emit IAccessControl.RoleRevoked(role, account, msg.sender);
            return true;
        } else {
            return false;
        }
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        bytes32 previousAdminRole = getRoleAdmin(role);
        ACStorage.AccessControlSlot().roles[role].adminRole = adminRole;
        emit IAccessControl.RoleAdminChanged(
            role,
            previousAdminRole,
            adminRole
        );
    }

    // ============================================== //
    //             INTERNAL READ FUNCTIONS            //
    // ============================================== //

    function DEFAULT_ADMIN_ROLE() internal pure returns (bytes32) {
        return bytes32(0);
    }

    function FOUNDER_ROLE() internal pure returns (bytes32) {
        return Constants.FOUNDER_ROLE;
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     * @param role The role to check.
     * @param account The account to check.
     */
    function onlyRole(bytes32 role, address account) internal view {
        require(
            hasRole(role, account),
            IAccessControl.AccessControlUnauthorizedAccount(account, role)
        );
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `msg.sender`
     * is missing `role`.
     * @param role The role to check.
     */
    function checkRole(bytes32 role) internal view {
        checkRole(role, msg.sender);
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert IAccessControl.AccessControlUnauthorizedAccount(
                account,
                role
            );
        }
    }

    /**
     * @notice check if account has role
     * @param role role
     * @param account account
     * @return bool true if account has role
     */
    function hasRole(
        bytes32 role,
        address account
    ) internal view returns (bool) {
        return ACStorage.AccessControlSlot().roles[role].hasRole[account];
    }

    /**
     * @notice get role admin
     * @param role role
     * @return bytes32 admin role
     */
    function getRoleAdmin(bytes32 role) internal view returns (bytes32) {
        return ACStorage.AccessControlSlot().roles[role].adminRole;
    }
}
