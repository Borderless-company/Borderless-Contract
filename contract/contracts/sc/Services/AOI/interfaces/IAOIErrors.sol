// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title Borderless AOI Errors v0.1.0
 */
interface IAOIErrors {
    /**
     * @dev Initial set chapter already set
     */
    error InitialSetChapterAlreadySet();

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
    error EphemeralSaltAlreadyUsed(bytes32 ephemeralSalt);
}
