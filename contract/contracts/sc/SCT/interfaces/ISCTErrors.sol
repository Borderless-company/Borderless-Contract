// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title ISCT Errors v0.1.0
 */
interface ISCTErrors {
    /**
     * @dev Notify that the account is invalid
     * @param account The address of the account that caused the error
     */
    error InvalidAddress(address account);

    /**
     * @dev Notify that the registrant is invalid
     * @param account The address of the account that caused the error
     */
    error InvalidRegister(address account);

    /**
     * @dev Notify that the account is not governance or founder
     * @param account The address of the account that caused the error
     */
    error NotGovernanceOrFounder(address account);

    /**
     * @dev Notify that the account is not founder or SCR
     * @param account The address of the account that caused the error
     */
    error NotFounderOrSCR(address account);
}
