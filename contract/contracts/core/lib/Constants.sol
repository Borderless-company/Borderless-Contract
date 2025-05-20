// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

library Constants {
    bytes32 internal constant DEFAULT_ADMIN_ROLE = bytes32(0);
    bytes32 internal constant FOUNDER_ROLE = keccak256("FOUNDER_ROLE");
    bytes32 internal constant TREASURY_ROLE = keccak256("TREASURY_ROLE");
    bytes32 internal constant SIGNATURE_ROLE = keccak256("SIGNATURE_ROLE");
    bytes32 internal constant ACCOUNTING_ROLE = keccak256("ACCOUNTING_ROLE");
}
