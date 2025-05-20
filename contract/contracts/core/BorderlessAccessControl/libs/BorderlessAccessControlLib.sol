// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage as ACStorage} from "../storages/Storage.sol";

// OpenZeppelin
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

library BorderlessAccessControlLib {
    /**
     * @notice check if account has role
     * @param role role
     * @param account account
     */
    function onlyRole(bytes32 role, address account) internal view {
        require(
            hasRole(role, account),
            IAccessControl.AccessControlUnauthorizedAccount(account, role)
        );
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
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
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(bytes32 role, address account) internal returns (bool) {
        if (!hasRole(role, account)) {
            ACStorage.AccessControlSlot()._roles[role].hasRole[account] = true;
            emit IAccessControl.RoleGranted(role, account, msg.sender);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Attempts to revoke `role` from `account` and returns a boolean indicating if `role` was revoked.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(bytes32 role, address account) internal returns (bool) {
        if (hasRole(role, account)) {
            ACStorage.AccessControlSlot()._roles[role].hasRole[account] = false;
            emit IAccessControl.RoleRevoked(role, account, msg.sender);
            return true;
        } else {
            return false;
        }
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        bytes32 previousAdminRole = getRoleAdmin(role);
        ACStorage.AccessControlSlot()._roles[role].adminRole = adminRole;
        emit IAccessControl.RoleAdminChanged(
            role,
            previousAdminRole,
            adminRole
        );
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
        return ACStorage.AccessControlSlot()._roles[role].hasRole[account];
    }

    /**
     * @notice get role admin
     * @param role role
     * @return bytes32 admin role
     */
    function getRoleAdmin(bytes32 role) internal view returns (bytes32) {
        return ACStorage.AccessControlSlot()._roles[role].adminRole;
    }
}
