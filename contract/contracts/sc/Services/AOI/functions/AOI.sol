// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// lib
import {AOILib} from "../libs/AOILib.sol";
import {AOIInitializeLib} from "../libs/AOIInitializeLib.sol";
import {BorderlessAccessControlLib} from "../../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";
import {Constants} from "../../../../core/lib/Constants.sol";

// interfaces
import {IAOI} from "../interfaces/IAOI.sol";
import {IAOIErrors} from "../interfaces/IAOIErrors.sol";

/**
 * @title AOI
 * @notice AOI is a contract that manages the AOI service.
 */
contract AOI is IAOI {
    // ************************************************
    // *                INITIALIZATION                *
    // ************************************************

    function initialize(address dictionary) public {
        AOIInitializeLib.initialize(dictionary);
    }

    // ************************************************
    // *           EXTERNAL WRITE FUNCTIONS           *
    // ************************************************

    /**
     * @dev Only FounderRole can call this function
     */
    function initialSetChapter(
        EncryptedItemInput[] calldata items
    ) external override {
        BorderlessAccessControlLib.onlyRole(Constants.FOUNDER_ROLE, msg.sender);
        require(
            !AOILib.getInitialSetChapter(),
            IAOIErrors.InitialSetChapterAlreadySet()
        );
        AOILib.setInitialSetChapter(true);
        AOILib.setChapter(items);
    }

    function setChapter(EncryptedItemInput[] calldata items) external override {
        BorderlessAccessControlLib.onlyRole(Constants.FOUNDER_ROLE, msg.sender);
        AOILib.setChapter(items);
    }

    function updateChapter(
        bytes32 versionRoot,
        address[] calldata signers,
        bytes[] calldata signatures,
        bytes calldata finalSignature,
        EncryptedItemInput[] calldata items
    ) external override {
        BorderlessAccessControlLib.onlyRole(Constants.FOUNDER_ROLE, msg.sender);
        AOILib.updateChapter(
            versionRoot,
            signers,
            signatures,
            finalSignature,
            items
        );
    }

    /**
     * @dev Only DefaultAdminRole can call this function
     */
    function setEphemeralSalt(bytes32 ephemeralSalt) external override {
        BorderlessAccessControlLib.onlyRole(Constants.FOUNDER_ROLE, msg.sender);
        require(
            !AOILib.getEphemeralSalt(ephemeralSalt),
            EphemeralSaltAlreadyUsed(ephemeralSalt)
        );
        AOILib.setEphemeralSalt(ephemeralSalt);
        emit EphemeralSaltMarkedUsed(ephemeralSalt);
    }

    // ************************************************
    // *            EXTERNAL READ FUNCTIONS           *
    // ************************************************

    function getEncryptedItem(
        ItemLocation calldata location
    ) external view returns (EncryptedItem memory) {
        return AOILib.getEncryptedItem(location.articleId, location.paragraphId, location.itemId);
    }

    function getVersionRoot(uint256 versionId) external view returns (bytes32) {
        return AOILib.getVersionRoot(versionId);
    }

    function isEphemeralSaltUsed(
        bytes32 ephemeralSalt
    ) external view returns (bool) {
        return AOILib.getEphemeralSalt(ephemeralSalt);
    }

    function verifyDecryptionKeyHash(
        ItemLocation calldata location,
        bytes32 expectedHash
    ) external view returns (bool) {
        return AOILib.verifyDecryptionKeyHash(location, expectedHash);
    }

    function verifyDecryptionKeyHashWithSaltHash(
        ItemLocation calldata location,
        bytes32 ephemeralSalt,
        bytes32 masterSaltHash,
        address holder
    ) external view returns (bool) {
        return
            AOILib.verifyDecryptionKeyHashWithSaltHash(
                location,
                ephemeralSalt,
                masterSaltHash,
                holder
            );
    }
}
