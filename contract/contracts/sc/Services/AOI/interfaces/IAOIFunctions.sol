// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IAOIStructs} from "./IAOIStructs.sol";

/**
 * @title Borderless AOI Functions v0.1.0
 */
interface IAOIFunctions {
    // ************************************************
    // *           EXTERNAL WRITE FUNCTIONS           *
    // ************************************************

    /**
     * @notice Initial set chapter
     * @param items Items
     */
    function initialSetChapter(
        IAOIStructs.EncryptedItemInput[] calldata items
    ) external;

    /**
     * @notice Set chapter
     * @param items Items
     */
    function setChapter(
        IAOIStructs.EncryptedItemInput[] calldata items
    ) external;

    /**
     * @notice Update chapter
     * @param versionRoot Version root
     * @param signers Signers
     * @param signatures Signatures
     * @param finalSignature Final signature
     * @param items Items
     */
    function updateChapter(
        bytes32 versionRoot,
        address[] calldata signers,
        bytes[] calldata signatures,
        bytes calldata finalSignature,
        IAOIStructs.EncryptedItemInput[] calldata items
    ) external;

    /**
     * @notice Set ephemeral salt as used
     * @param ephemeralSalt Ephemeral salt
     */
    function setEphemeralSalt(bytes32 ephemeralSalt) external;

    // ************************************************
    // *            EXTERNAL READ FUNCTIONS           *
    // ************************************************

    /**
     * @notice Get encrypted item
     * @param location Item location
     * @return Encrypted item
     */
    function getEncryptedItem(
        IAOIStructs.ItemLocation calldata location
    ) external view returns (IAOIStructs.EncryptedItem memory);

    /**
     * @notice Get version root
     * @param versionId Version ID
     * @return Version root
     */
    function getVersionRoot(uint256 versionId) external view returns (bytes32);

    function isEphemeralSaltUsed(
        bytes32 ephemeralSalt
    ) external view returns (bool);

    /**
     * @notice Verify decryption key hash
     * @param location Item location
     * @param expectedHash Expected hash
     * @return True if the hash is valid
     */
    function verifyDecryptionKeyHash(
        IAOIStructs.ItemLocation calldata location,
        bytes32 expectedHash
    ) external view returns (bool);

    /**
     * @notice Verify decryption key hash with salt hash
     * @param location Item location
     * @param ephemeralSalt Ephemeral salt
     * @param masterSaltHash Master salt hash
     * @param holder Holder
     * @return True if the hash is valid
     */
    function verifyDecryptionKeyHashWithSaltHash(
        IAOIStructs.ItemLocation calldata location,
        bytes32 ephemeralSalt,
        bytes32 masterSaltHash,
        address holder
    ) external view returns (bool);
}