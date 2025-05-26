// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage as AOIStorage} from "../storages/Storage.sol";

// interfaces
import {IAOIStructs} from "../interfaces/IAOIStructs.sol";
import {IAOIErrors} from "../interfaces/IAOIErrors.sol";
import {IAOIEvents} from "../interfaces/IAOIEvents.sol";

// OpenZeppelin
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

library AOILib {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;
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

    function updateChapter(
        bytes32 versionRoot,
        address[] calldata signers,
        bytes[] calldata signatures,
        bytes memory finalSignature,
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

        _emitChapterUpdated(versionId, versionRoot, finalSigner, signers, items);
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
        AOIStorage.AOISlot().encryptedItems[item.location.articleId][item.location.paragraphId][
            item.location.itemId
        ] = IAOIStructs.EncryptedItem(
            item.encryptedData,
            item.plaintextHash,
            item.masterSaltHash
        );
    }

    // ************************************************
    // *            INTERNAL READ FUNCTIONS           *
    // ************************************************

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
