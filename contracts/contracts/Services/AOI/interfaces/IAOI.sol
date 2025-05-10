// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IAOI {
    // ************************************************
    // *                     EVENTS                   *
    // ************************************************

    /**
     * @dev Chapter updated
     * @param versionId Version ID
     * @param versionRoot Version root
     * @param finalSigner Final signer
     * @param signers Signers
     * @param updatedLocations Updated locations
     */
    event ChapterUpdated(
        uint256 versionId,
        bytes32 versionRoot,
        address finalSigner,
        address[] signers,
        ItemLocation[] updatedLocations
    );

    /**
     * @dev Ephemeral salt marked used
     * @param ephemeralSalt Ephemeral salt
     */
    event EphemeralSaltMarkedUsed(bytes32 ephemeralSalt);

    /**
     * @dev Governance updated
     * @param governance Governance
     */
    event GovernanceUpdated(address governance);

    /**
     * @dev Token updated
     * @param token Token
     */
    event TokenUpdated(address token);

    // ************************************************
    // *                     ERRORS                   *
    // ************************************************

    /**
     * @dev Length mismatch
     */
    error LengthMismatch();

    /**
     * @dev Not governance
     */
    error NotGovernance(address sender, address governance);

    /**
     * @dev Invalid articleId
     */
    error InvalidArticleId(uint256 articleId);

    /**
     * @dev Invalid signature
     */
    error InvalidSignature(address recovered, address signer);

    /**
     * @dev Ephemeral salt already used
     */
    error EphemeralSaltAlreadyUsed(
        bytes32 ephemeralSalt
    );

    // ************************************************
    // *                    STRUCTS                   *
    // ************************************************

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

    // ************************************************
    // *           EXTERNAL WRITE FUNCTIONS           *
    // ************************************************

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
        EncryptedItemInput[] calldata items
    ) external;

    /**
     * @notice Set ephemeral salt as used
     * @param ephemeralSalt Ephemeral salt
     */
    function setEphemeralSalt(bytes32 ephemeralSalt) external;

    /**
     * @notice Set governance
     * @param governance Governance
     */
    function setGovernance(address governance) external;

    /**
     * @notice Set token
     * @param token Token
     */
    function setToken(address token) external;

    // ************************************************
    // *            EXTERNAL READ FUNCTIONS           *
    // ************************************************

    /**
     * @notice Get encrypted item
     * @param location Item location
     * @return Encrypted item
     */
    function getEncryptedItem(
        ItemLocation calldata location
    ) external view returns (EncryptedItem memory);

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
        ItemLocation calldata location,
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
        ItemLocation calldata location,
        bytes32 ephemeralSalt,
        bytes32 masterSaltHash,
        address holder
    ) external view returns (bool);

    /**
     * @notice Get governance
     * @return Governance
     */
    function getGovernance() external view returns (address);

    /**
     * @notice Get token
     * @return Token
     */
    function getToken() external view returns (address);
}