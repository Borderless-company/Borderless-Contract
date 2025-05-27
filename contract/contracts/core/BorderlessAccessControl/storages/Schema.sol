// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title AccessControlUpgradeable Schema v0.1.0
 */
library Schema {
    struct RoleData {
        mapping(address account => bool) hasRole;
        bytes32 adminRole;
    }

    struct AccessControlLayout {
        mapping(bytes32 role => RoleData) roles;
    }
}
