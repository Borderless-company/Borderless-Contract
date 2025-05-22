// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage} from "../storages/Storage.sol";

// lib
import {BorderlessAccessControlLib} from "../libs/BorderlessAccessControlLib.sol";
import {BorderlessAccessControlInitializeLib} from "../../Initialize/libs/BorderlessAccessControlInitializeLib.sol";

// OpenZeppelin
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

contract BorderlessAccessControl is Context, IAccessControl, ERC165 {
    function initialize(address dictionary) public {
        BorderlessAccessControlInitializeLib.initialize(dictionary);
    }

    /**
     * @dev Returns the default admin role.
     */
    function DEFAULT_ADMIN_ROLE() public pure returns (bytes32) {
        return BorderlessAccessControlLib.DEFAULT_ADMIN_ROLE();
    }

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
        BorderlessAccessControlLib.checkRole(role);
    }

    /**
     * @dev Reverts with an {AccessControlUnauthorizedAccount} error if `account`
     * is missing `role`.
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        BorderlessAccessControlLib.checkRole(role, account);
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
    ) public virtual onlyRole(BorderlessAccessControlLib.getRoleAdmin(role)) {
        BorderlessAccessControlLib.grantRole(role, account);
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
    ) public virtual onlyRole(BorderlessAccessControlLib.getRoleAdmin(role)) {
        BorderlessAccessControlLib.revokeRole(role, account);
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

        BorderlessAccessControlLib.revokeRole(role, callerConfirmation);
    }

    // ============================================== //
    //               Override IAccessControl          //
    // ============================================== //

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return BorderlessAccessControlLib.getRoleAdmin(role);
    }

    function hasRole(
        bytes32 role,
        address account
    ) public view override returns (bool) {
        return BorderlessAccessControlLib.hasRole(role, account);
    }
}
