// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title IDictionaryFunctions
 * @notice IDictionaryFunctions is an interface that defines the functions for the Dictionary contract.
 */
interface IDictionaryFunctions {
    // ============================================== //
    //              EXTERNAL WRITE FUNCTIONS          //
    // ============================================== //

    /**
     * @notice set implementation address
     * @param selector function selector
     * @param implementation implementation address
     */
    function setImplementation(
        bytes4 selector,
        address implementation
    ) external;

    /**
     * @notice bulk set implementation address
     * @param selectors function selectors
     * @param implementation implementation address
     */
    function bulkSetImplementation(
        bytes4[] memory selectors,
        address implementation
    ) external;

    /**
     * @notice bulk set implementation address
     * @param selectors function selectors
     * @param implementations implementation addresses
     */
    function bulkSetImplementation(
        bytes4[] memory selectors,
        address[] memory implementations
    ) external;

    /**
     * @notice upgrade facade
     * @param newFacade new facade address
     */
    function upgradeFacade(address newFacade) external;

    /**
     * @notice set once initialized
     * @param account account address
     * @param implementation implementation address
     */
    function setOnceInitialized(
        address account,
        address implementation
    ) external;

    // ============================================== //
    //              EXTERNAL READ FUNCTIONS           //
    // ============================================== //

    /**
     * @notice get facade address
     * @return facade address
     */
    function getFacade() external view returns (address);
}
