// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title Borderless AOI Structs v0.1.0
 */
interface IAOIStructs {
    /**
     * @dev Item location
     * @param articleId Article ID
     * @param paragraphId Paragraph ID
     * @param itemId Item ID
     */
    struct ItemLocation {
        uint256 articleId;
        uint256 paragraphId;
        uint256 itemId;
    }

    /**
     * @dev Encrypted item
     * @param encryptedData Encrypted data
     * @param plaintextHash Plaintext hash
     * @param masterSaltHash Master salt hash
     */
    struct EncryptedItem {
        bytes encryptedData;
        bytes32 plaintextHash;
        bytes32 masterSaltHash;
    }

    /**
     * @dev Encrypted item input
     * @param location Item location
     * @param encryptedData Encrypted data
     * @param plaintextHash Plaintext hash
     * @param masterSaltHash Master salt hash
     */
    struct EncryptedItemInput {
        ItemLocation location;
        bytes encryptedData;
        bytes32 plaintextHash;
        bytes32 masterSaltHash;
    }
}
