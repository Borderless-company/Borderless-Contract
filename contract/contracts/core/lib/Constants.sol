// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title Constants
 * @notice Constants is a library that provides constant values for the core contracts.
 */
library Constants {
    bytes32 internal constant DEFAULT_ADMIN_ROLE = bytes32(0);
    bytes32 internal constant FOUNDER_ROLE = keccak256("FOUNDER_ROLE");
    bytes32 internal constant TREASURY_ROLE = keccak256("TREASURY_ROLE");
    bytes32 internal constant SIGNATURE_ROLE = keccak256("SIGNATURE_ROLE");
    bytes32 internal constant ACCOUNTING_ROLE = keccak256("ACCOUNTING_ROLE");
    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");
}
