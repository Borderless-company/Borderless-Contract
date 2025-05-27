// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title IDictionaryErrors
 * @notice IDictionaryErrors is an interface that defines the errors for the Dictionary contract.
 */
interface IDictionaryErrors {
    /**
     * @dev not owner or initialized
     * @param account account address
     * @param implementation implementation address
     */
    error NotOwnerOrInitialized(address account, address implementation);
}