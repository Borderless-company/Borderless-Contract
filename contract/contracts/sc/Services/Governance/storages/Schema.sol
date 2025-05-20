// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IGovernanceServiceStructs} from "../interfaces/IGovernanceServiceStructs.sol";

/**
 * @title Borderless Governance Schema v0.1.0
 */
library Schema {
    struct GovernanceLayout {
        uint256 lastTransactionId;
        mapping(uint256 => IGovernanceServiceStructs.Transaction) transactions;
        mapping(uint256 => mapping(address => bool)) approvals;
        /**
         * @dev index => function selector
         */
        mapping(uint256 => bytes4) selectors;
        /**
         * @dev number of registered selectors
         */
        uint256 selectorIndex;
    }
}
