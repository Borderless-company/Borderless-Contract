// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Schema} from "../storages/Schema.sol";

// OpenZeppelin
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

library AccessControlLib {
    /**
     * @notice check if account has role
     * @param slot access control layout
     * @param role role
     * @param account account
     */
    function onlyRole(
        Schema.AccessControlLayout storage slot,
        bytes32 role,
        address account
    ) internal view {
        require(
            slot._roles[role].hasRole[account],
            IAccessControl.AccessControlUnauthorizedAccount(account, role)
        );
    }

    /**
     * @notice check if account has role
     * @param slot access control layout
     * @param role role
     * @param account account
     * @return bool true if account has role
     */
    function hasRole(
        Schema.AccessControlLayout storage slot,
        bytes32 role,
        address account
    ) internal view returns (bool) {
        return slot._roles[role].hasRole[account];
    }

    /**
     * @notice get role admin
     * @param slot access control layout
     * @param role role
     * @return bytes32 admin role
     */
    function getRoleAdmin(
        Schema.AccessControlLayout storage slot,
        bytes32 role
    ) internal view returns (bytes32) {
        return slot._roles[role].adminRole;
    }
}
