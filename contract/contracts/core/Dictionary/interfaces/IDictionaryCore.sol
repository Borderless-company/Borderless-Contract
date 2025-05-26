// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IDictionaryCore {
    // ============================================== //
    //                  Events                        //
    // ============================================== //

    /**
     * @dev new function selector added
     * @param newSelector new function selector
     */
    event NewFunctionSelectorAdded(bytes4 newSelector);

    /**
     * @dev implementation deleted
     * @param selector function selector
     */
    event ImplementationDeleted(bytes4 selector);

    /**
     * @dev implementation upgraded
     * @param selector function selector
     * @param newImplementation new implementation address
     */
    event ImplementationUpgraded(bytes4 selector, address newImplementation);

    // ============================================== //
    //                  Errors                        //
    // ============================================== //

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

    // ============================================== //
    //              External Read Functions           //
    // ============================================== //

    /**
     * @dev get implementation address by function selector
     * @param selector function selector
     * @return implementation address
     */
    function getImplementation(bytes4 selector) external view returns (address);
}