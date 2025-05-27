// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title IDictionaryCoreErrors
 * @notice IDictionaryCoreErrors is an interface that defines the errors for the Dictionary contract.
 */
interface IDictionaryCoreErrors {
    /**
     * @dev implementation not found
     * @param selector function selector
     */
    error ImplementationNotFound(bytes4 selector);

    /**
     * @dev invalid implementation
     * @param implementation implementation address
     */
    error InvalidImplementation(address implementation);

    /**
     * @dev invalid bulk length
     * @param selectors length of selectors
     * @param implementations length of implementations
     */
    error InvalidBulkLength(uint256 selectors, uint256 implementations);
}