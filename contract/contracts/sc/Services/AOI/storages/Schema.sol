// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IAOI} from "../interfaces/IAOI.sol";

/**
 * @title Borderless AOI Schema v0.1.0
 */
library Schema {
    struct AOILayout {
        /**
         * @dev initialSetChapter
         */
        bool initialSetChapter;
        /**
         * @dev articleId => paragraphId => itemId => EncryptedItem
         */
        mapping(uint256 => mapping(uint256 => mapping(uint256 => IAOI.EncryptedItem))) encryptedItems;
        /**
         * @dev versionId => versionRoot
         */
        mapping(uint256 => bytes32) versionRoots;
        /**
         * @dev ephemeralSalt => used
         */
        mapping(bytes32 => bool) usedEphemeralSalts;
    }
}
