// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage as AOIStorage} from "../storages/Storage.sol";

// lib
import {Address} from "../../../../core/lib/Address.sol";

// interfaces
import {IAOIStructs} from "../interfaces/IAOIStructs.sol";
import {IAOIErrors} from "../interfaces/IAOIErrors.sol";
import {IAOIEvents} from "../interfaces/IAOIEvents.sol";
import {SCTLib} from "../../../SCT/libs/SCTLib.sol";
import {ServiceType} from "../../../../core/utils/ITypes.sol";

// OpenZeppelin
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title AOILib
 * @notice AOILib is a library that manages the AOI service.
 */
library AOILib {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    // ************************************************
    // *                WRITE FUNCTIONS               *
    // ************************************************

    /**
     * @notice Set the chapter
     * @param items The items
     */
    function setChapter(
        IAOIStructs.EncryptedItemInput[] calldata items
    ) internal {
        bytes32[] memory leaves = new bytes32[](items.length);
        for (uint256 i = 0; i < items.length; i++) {
            _setEncryptedItem(items[i]);
            leaves[i] = items[i].plaintextHash;
        }

        bytes32 versionRoot = _computeMerkleRoot(leaves);

        bytes32 initialVersionRoot = _computeMerkleRoot(leaves);
        AOIStorage.AOISlot().versionRoots[0] = initialVersionRoot;

        _emitChapterUpdated(
            0,
            initialVersionRoot,
            address(0),
            new address[](0),
            items
        );
    }

    /**
     * @notice Update the chapter
     * @param versionRoot The version root
     * @param signers The signers
     * @param signatures The signatures
     * @param finalSignature The final signature
     * @param items The items
     */
    function updateChapter(
        bytes32 versionRoot,
        address[] calldata signers,
        bytes[] calldata signatures,
        bytes calldata finalSignature,
        IAOIStructs.EncryptedItemInput[] calldata items
    ) internal {
        (address finalSigner, ) = _verifyFinalAndAllSigners(
            versionRoot,
            signers,
            signatures,
            finalSignature
        );

        for (uint256 i = 0; i < items.length; i++) {
            _setEncryptedItem(items[i]);
        }

        uint256 versionId = uint256(versionRoot);
        AOIStorage.AOISlot().versionRoots[versionId] = versionRoot;

        _emitChapterUpdated(
            versionId,
            versionRoot,
            finalSigner,
            signers,
            items
        );
    }

    /**
     * @notice Set the initial set chapter
     */
    function setInitialSetChapter(bool initialSetChapter) internal {
        AOIStorage.AOISlot().initialSetChapter = initialSetChapter;
    }

    /**
     * @notice Set the ephemeral salt
     * @param ephemeralSalt The ephemeral salt
     */
    function setEphemeralSalt(bytes32 ephemeralSalt) internal {
        AOIStorage.AOISlot().usedEphemeralSalts[ephemeralSalt] = true;
    }

    // ************************************************
    // *                READ FUNCTIONS                *
    // ************************************************

    /**
     * @notice Get the initial set chapter
     * @return The initial set chapter
     */
    function getInitialSetChapter() internal view returns (bool) {
        return AOIStorage.AOISlot().initialSetChapter;
    }

    /**
     * @notice Get the encrypted item
     * @param articleId The article id
     * @param paragraphId The paragraph id
     * @param itemId The item id
     * @return The encrypted item
     */
    function getEncryptedItem(
        uint256 articleId,
        uint256 paragraphId,
        uint256 itemId
    ) internal view returns (IAOIStructs.EncryptedItem memory) {
        return
            AOIStorage.AOISlot().encryptedItems[articleId][paragraphId][itemId];
    }

    /**
     * @notice Get the version root
     * @param versionId The version id
     * @return The version root
     */
    function getVersionRoot(uint256 versionId) internal view returns (bytes32) {
        return AOIStorage.AOISlot().versionRoots[versionId];
    }

    /**
     * @notice Get the ephemeral salt
     * @param ephemeralSalt The ephemeral salt
     * @return The ephemeral salt
     */
    function getEphemeralSalt(
        bytes32 ephemeralSalt
    ) internal view returns (bool) {
        return AOIStorage.AOISlot().usedEphemeralSalts[ephemeralSalt];
    }

    /**
     * @notice Verify the decryption key hash
     * @param location The location
     * @param expectedHash The expected hash
     * @return The verification result
     */
    function verifyDecryptionKeyHash(
        IAOIStructs.ItemLocation calldata location,
        bytes32 expectedHash
    ) internal view returns (bool) {
        return
            getEncryptedItem(location.articleId, location.paragraphId, location.itemId).plaintextHash == expectedHash;
    }

    function verifyDecryptionKeyHashWithSaltHash(
        IAOIStructs.ItemLocation calldata location,
        bytes32 ephemeralSalt,
        bytes32 masterSaltHash,
        address holder
    ) internal view returns (bool) {
        address letsExe = SCTLib.getService(ServiceType.LETS_EXE);
        Address.checkZeroAddress(letsExe);
        return !getEphemeralSalt(ephemeralSalt) &&
            getEncryptedItem(location.articleId, location.paragraphId, location.itemId).masterSaltHash == masterSaltHash &&
            IERC721(letsExe).balanceOf(holder) > 0;
    }

    // ************************************************
    // *            INTERNAL WRITE FUNCTIONS          *
    // ************************************************

    function _computeMerkleRoot(
        bytes32[] memory leaves
    ) internal pure returns (bytes32) {
        while (leaves.length > 1) {
            uint256 len = leaves.length;
            uint256 newLen = (len + 1) / 2;
            bytes32[] memory next = new bytes32[](newLen);
            for (uint256 i = 0; i < len; i += 2) {
                next[i / 2] = (i + 1 < len)
                    ? keccak256(abi.encodePacked(leaves[i], leaves[i + 1]))
                    : leaves[i];
            }
            leaves = next;
        }
        return leaves[0];
    }

    function _emitChapterUpdated(
        uint256 versionId,
        bytes32 versionRoot,
        address finalSigner,
        address[] memory signers,
        IAOIStructs.EncryptedItemInput[] memory items
    ) internal {
        IAOIStructs.ItemLocation[]
            memory locations = new IAOIStructs.ItemLocation[](items.length);
        for (uint256 i = 0; i < items.length; i++) {
            locations[i] = items[i].location;
        }
        emit IAOIEvents.ChapterUpdated(
            versionId,
            versionRoot,
            finalSigner,
            signers,
            locations
        );
    }

    function _setEncryptedItem(
        IAOIStructs.EncryptedItemInput memory item
    ) internal {
        require(
            item.location.articleId >= 1,
            IAOIErrors.InvalidArticleId(item.location.articleId)
        );
        AOIStorage.AOISlot().encryptedItems[item.location.articleId][
            item.location.paragraphId
        ][item.location.itemId] = IAOIStructs.EncryptedItem(
            item.encryptedData,
            item.plaintextHash,
            item.masterSaltHash
        );
    }

    /**
     * @notice Verify the final signature and all signers
     * @param versionRoot The version root
     * @param signers The signers
     * @param signatures The signatures
     * @param finalSignature The final signature
     * @return finalSigner The final signer
     * @return recoveredSigners The recovered signers
     */
    function _verifyFinalAndAllSigners(
        bytes32 versionRoot,
        address[] memory signers,
        bytes[] memory signatures,
        bytes memory finalSignature
    )
        internal
        pure
        returns (address finalSigner, address[] memory recoveredSigners)
    {
        require(
            signers.length == signatures.length,
            IAOIErrors.LengthMismatch()
        );
        recoveredSigners = new address[](signers.length);

        for (uint256 i = 0; i < signers.length; i++) {
            bytes32 hash = keccak256(abi.encodePacked(versionRoot))
                .toEthSignedMessageHash();
            address recovered = hash.recover(signatures[i]);
            require(
                recovered == signers[i],
                IAOIErrors.InvalidSignature(recovered, signers[i])
            );
            recoveredSigners[i] = recovered;
        }

        bytes32 metaHash = keccak256(
            abi.encode(versionRoot, signers, signatures)
        ).toEthSignedMessageHash();
        finalSigner = metaHash.recover(finalSignature);
    }
}
