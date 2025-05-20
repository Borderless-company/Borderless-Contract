// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title Ownable Errors
 */
interface IOwnableErrors {
    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);
}
