// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IAOIStructs} from "./IAOIStructs.sol";

/**
 * @title Borderless AOI Events v0.1.0
 */
interface IAOIEvents {
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
        IAOIStructs.ItemLocation[] updatedLocations
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
}