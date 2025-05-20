// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage as AOIStorage} from "../storages/Storage.sol";

// lib
import {AOILib} from "../libs/AOILib.sol";
import {AOIInitializeLib} from "../../../../core/Initialize/libs/AOIInitializeLib.sol";
import {BorderlessAccessControlLib} from "../../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";
import {Constants} from "../../../../core/lib/Constants.sol";
import {ERC721Lib} from "../../../../sc/ERC721/libs/ERC721Lib.sol";

// interfaces
import {IAOI} from "../interfaces/IAOI.sol";
import {IAOIErrors} from "../interfaces/IAOIErrors.sol";

// OpenZeppelin
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

contract AOI is IAOI {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

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
        BorderlessAccessControlLib.onlyRole(
            Constants.FOUNDER_ROLE,
            msg.sender
        );
        require(
            !AOIStorage.AOISlot().initialSetChapter,
            IAOIErrors.InitialSetChapterAlreadySet()
        );
        AOIStorage.AOISlot().initialSetChapter = true;
        AOILib.setChapter(items);
    }

    /**
     * @dev Only DefaultAdminRole can call this function
     */
    function setEphemeralSalt(bytes32 ephemeralSalt) external override {
        BorderlessAccessControlLib.onlyRole(
            Constants.FOUNDER_ROLE,
            msg.sender
        );
        require(
            !AOIStorage.AOISlot().usedEphemeralSalts[ephemeralSalt],
            EphemeralSaltAlreadyUsed(ephemeralSalt)
        );
        AOIStorage.AOISlot().usedEphemeralSalts[ephemeralSalt] = true;
        emit EphemeralSaltMarkedUsed(ephemeralSalt);
    }

    // ************************************************
    // *            EXTERNAL READ FUNCTIONS           *
    // ************************************************

    function getEncryptedItem(
        ItemLocation calldata location
    ) external view returns (EncryptedItem memory) {
        return
            AOIStorage.AOISlot().encryptedItems[location.articleId][location.paragraphId][
                location.itemId
            ];
    }

    function getVersionRoot(uint256 versionId) external view returns (bytes32) {
        return AOIStorage.AOISlot().versionRoots[versionId];
    }

    function isEphemeralSaltUsed(
        bytes32 ephemeralSalt
    ) external view returns (bool) {
        return AOIStorage.AOISlot().usedEphemeralSalts[ephemeralSalt];
    }

    function verifyDecryptionKeyHash(
        ItemLocation calldata location,
        bytes32 expectedHash
    ) external view returns (bool) {
        return
            AOIStorage.AOISlot().encryptedItems[location.articleId][location.paragraphId][
                location.itemId
            ].plaintextHash == expectedHash;
    }

    function verifyDecryptionKeyHashWithSaltHash(
        ItemLocation calldata location,
        bytes32 ephemeralSalt,
        bytes32 masterSaltHash,
        address holder
    ) external view returns (bool) {
        return (!AOIStorage.AOISlot().usedEphemeralSalts[ephemeralSalt] &&
            AOIStorage.AOISlot().encryptedItems[location.articleId][location.paragraphId][
                location.itemId
            ].masterSaltHash ==
            masterSaltHash &&
            ERC721Lib.balanceOf(holder) > 0);
    }
}
