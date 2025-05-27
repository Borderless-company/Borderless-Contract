// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title IDictionaryCoreEvents
 * @notice IDictionaryCoreEvents is an interface that defines the events for the Dictionary contract.
 */
interface IDictionaryCoreEvents {
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
}