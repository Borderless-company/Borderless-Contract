// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IAOI} from "./interfaces/IAOI.sol";

// OpenZeppelin
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract AOI is IAOI, Initializable, AccessControlUpgradeable {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;

    // ************************************************
    // *                   STORAGES                   *
    // ************************************************

    address private _governance;
    address private _token;

    /** 英語に直す
     * @dev articleId => paragraphId => itemId => EncryptedItem
     */
    mapping(uint256 => mapping(uint256 => mapping(uint256 => EncryptedItem)))
        public encryptedItems;

    /**
     * @dev versionId => versionRoot
     */
    mapping(uint256 => bytes32) public versionRoots;

    /**
     * @dev ephemeralSalt => used
     */
    mapping(bytes32 => bool) public usedEphemeralSalts;

    // ************************************************
    // *                 MODIFIERS                    *
    // ************************************************

    modifier onlyGovernance() {
        require(
            msg.sender == _governance,
            NotGovernance(msg.sender, _governance)
        );
        _;
    }

    // ************************************************
    // *                 CONSTRUCTOR                  *
    // ************************************************

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ************************************************
    // *                 INITIALIZER                  *
    // ************************************************

    function initialize(
        address admin,
        address governance,
        address token,
        EncryptedItemInput[] memory items
    ) public initializer {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _governance = governance;
        _token = token;

        bytes32[] memory leaves = new bytes32[](items.length);

        for (uint256 i = 0; i < items.length; i++) {
            _setEncryptedItem(items[i]);
            leaves[i] = items[i].plaintextHash;
        }

        bytes32 initialVersionRoot = _computeMerkleRoot(leaves);
        versionRoots[0] = initialVersionRoot;

        _emitChapterUpdated(
            0,
            initialVersionRoot,
            address(0),
            new address[](0),
            items
        );
    }

    // ************************************************
    // *           EXTERNAL WRITE FUNCTIONS           *
    // ************************************************

    /**
     * @dev Only Governance can call this function
     */
    function updateChapter(
        bytes32 versionRoot,
        address[] calldata signers,
        bytes[] calldata signatures,
        bytes memory finalSignature,
        EncryptedItemInput[] calldata items
    ) external override onlyGovernance {
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
        versionRoots[versionId] = versionRoot;

        _emitChapterUpdated(
            versionId,
            versionRoot,
            finalSigner,
            signers,
            items
        );
    }

    /**
     * @dev Only DefaultAdminRole can call this function
     */
    function setEphemeralSalt(
        bytes32 ephemeralSalt
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            !usedEphemeralSalts[ephemeralSalt],
            EphemeralSaltAlreadyUsed(ephemeralSalt)
        );
        usedEphemeralSalts[ephemeralSalt] = true;
        emit EphemeralSaltMarkedUsed(ephemeralSalt);
    }

    /**
     * @dev Only DefaultAdminRole can call this function
     */
    function setGovernance(
        address governance
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _governance = governance;
        emit GovernanceUpdated(governance);
    }

    /**
     * @dev Only DefaultAdminRole can call this function
     */
    function setToken(
        address token
    ) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        _token = token;
        emit TokenUpdated(token);
    }

    // ************************************************
    // *            INTERNAL WRITE FUNCTIONS          *
    // ************************************************

    function _setEncryptedItem(EncryptedItemInput memory item) internal {
        require(
            item.location.articleId >= 1,
            InvalidArticleId(item.location.articleId)
        );
        encryptedItems[item.location.articleId][item.location.paragraphId][
            item.location.itemId
        ] = EncryptedItem(
            item.encryptedData,
            item.plaintextHash,
            item.masterSaltHash
        );
    }

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
        EncryptedItemInput[] memory items
    ) internal {
        ItemLocation[] memory locations = new ItemLocation[](items.length);
        for (uint256 i = 0; i < items.length; i++) {
            locations[i] = items[i].location;
        }
        emit ChapterUpdated(
            versionId,
            versionRoot,
            finalSigner,
            signers,
            locations
        );
    }

    // ************************************************
    // *            EXTERNAL READ FUNCTIONS           *
    // ************************************************

    function getEncryptedItem(
        ItemLocation calldata location
    ) external view returns (EncryptedItem memory) {
        return
            encryptedItems[location.articleId][location.paragraphId][
                location.itemId
            ];
    }

    function getVersionRoot(uint256 versionId) external view returns (bytes32) {
        return versionRoots[versionId];
    }

    function isEphemeralSaltUsed(
        bytes32 ephemeralSalt
    ) external view returns (bool) {
        return usedEphemeralSalts[ephemeralSalt];
    }

    function verifyDecryptionKeyHash(
        ItemLocation calldata location,
        bytes32 expectedHash
    ) external view returns (bool) {
        return
            encryptedItems[location.articleId][location.paragraphId][
                location.itemId
            ].plaintextHash == expectedHash;
    }

    function verifyDecryptionKeyHashWithSaltHash(
        ItemLocation calldata location,
        bytes32 ephemeralSalt,
        bytes32 masterSaltHash,
        address holder
    ) external view returns (bool) {
        return (!usedEphemeralSalts[ephemeralSalt] &&
            encryptedItems[location.articleId][location.paragraphId][
                location.itemId
            ].masterSaltHash ==
            masterSaltHash &&
            IERC721(_token).balanceOf(holder) > 0);
    }

    function getGovernance() external view override returns (address) {
        return _governance;
    }

    function getToken() external view override returns (address) {
        return _token;
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
        require(signers.length == signatures.length, LengthMismatch());
        recoveredSigners = new address[](signers.length);

        for (uint256 i = 0; i < signers.length; i++) {
            bytes32 hash = keccak256(abi.encodePacked(versionRoot))
                .toEthSignedMessageHash();
            address recovered = hash.recover(signatures[i]);
            require(
                recovered == signers[i],
                InvalidSignature(recovered, signers[i])
            );
            recoveredSigners[i] = recovered;
        }

        bytes32 metaHash = keccak256(
            abi.encode(versionRoot, signers, signatures)
        ).toEthSignedMessageHash();
        finalSigner = metaHash.recover(finalSignature);
    }
}
