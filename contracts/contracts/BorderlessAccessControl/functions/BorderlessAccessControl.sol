// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage} from "../storages/Storage.sol";

// lib
import {AccessControlLib} from "../lib/AccessControlLib.sol";
import {Constants} from "../../lib/Constants.sol";

// OpenZeppelin
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC165, ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract BorderlessAccessControl is Context, IAccessControl, ERC165 {
    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role);
        _;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override returns (bool) {
        return
            interfaceId == type(IAccessControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `_msgSender()`
     * is missing `role`. Overriding this function changes the behavior of the {onlyRole} modifier.
     */
    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (
            !AccessControlLib.hasRole(
                Storage.AccessControlSlot(),
                role,
                account
            )
        ) {
            revert AccessControlUnauthorizedAccount(account, role);
        }
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleGranted} event.
     */
    function grantRole(
        bytes32 role,
        address account
    )
        public
        virtual
        onlyRole(
            AccessControlLib.getRoleAdmin(Storage.AccessControlSlot(), role)
        )
    {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     *
     * May emit a {RoleRevoked} event.
     */
    function revokeRole(
        bytes32 role,
        address account
    )
        public
        virtual
        onlyRole(
            AccessControlLib.getRoleAdmin(Storage.AccessControlSlot(), role)
        )
    {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `callerConfirmation`.
     *
     * May emit a {RoleRevoked} event.
     */
    function renounceRole(
        bytes32 role,
        address callerConfirmation
    ) public virtual {
        if (callerConfirmation != _msgSender()) {
            revert AccessControlBadConfirmation();
        }

        _revokeRole(role, callerConfirmation);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = AccessControlLib.getRoleAdmin(
            Storage.AccessControlSlot(),
            role
        );
        Storage.AccessControlSlot()._roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Attempts to grant `role` to `account` and returns a boolean indicating if `role` was granted.
     *
     * Internal function without access restriction.
     *
     * May emit a {RoleGranted} event.
     */
    function _grantRole(
        bytes32 role,
        address account
    ) internal virtual returns (bool) {
        if (
            !AccessControlLib.hasRole(
                Storage.AccessControlSlot(),
                role,
                account
            )
        ) {
            Storage.AccessControlSlot()._roles[role].hasRole[account] = true;
            emit RoleGranted(role, account, _msgSender());
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
    function _revokeRole(
        bytes32 role,
        address account
    ) internal virtual returns (bool) {
        if (
            AccessControlLib.hasRole(Storage.AccessControlSlot(), role, account)
        ) {
            Storage.AccessControlSlot()._roles[role].hasRole[account] = false;
            emit RoleRevoked(role, account, _msgSender());
            return true;
        } else {
            return false;
        }
    }

    // ============================================== //
    //               Override IAccessControl          //
    // ============================================== //

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return AccessControlLib.getRoleAdmin(Storage.AccessControlSlot(), role);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return AccessControlLib.hasRole(Storage.AccessControlSlot(), role, account);
    }
}
