// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {IAOI} from "../interfaces/IAOI.sol";
import {IAOIStructs} from "../interfaces/IAOIStructs.sol";

/**
 * @title AOIProxy
 * @notice Proxy contract for the AOI contract
 */
contract AOIProxy is IAOI {
    // ************************************************
    // *           EXTERNAL WRITE FUNCTIONS           *
    // ************************************************

    function initialSetChapter(
        IAOIStructs.EncryptedItemInput[] calldata items
    ) external {}

    function setEphemeralSalt(bytes32 ephemeralSalt) external {}

    // ************************************************
    // *            EXTERNAL READ FUNCTIONS           *
    // ************************************************

    function getEncryptedItem(
        IAOIStructs.ItemLocation calldata location
    ) external view returns (IAOIStructs.EncryptedItem memory) {}

    function getVersionRoot(
        uint256 versionId
    ) external view returns (bytes32) {}

    function isEphemeralSaltUsed(
        bytes32 ephemeralSalt
    ) external view returns (bool) {}

    function verifyDecryptionKeyHash(
        IAOIStructs.ItemLocation calldata location,
        bytes32 expectedHash
    ) external view returns (bool) {}

    function verifyDecryptionKeyHashWithSaltHash(
        IAOIStructs.ItemLocation calldata location,
        bytes32 ephemeralSalt,
        bytes32 masterSaltHash,
        address holder
    ) external view returns (bool) {}
}
