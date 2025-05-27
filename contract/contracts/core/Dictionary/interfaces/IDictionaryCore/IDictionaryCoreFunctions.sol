// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title IDictionaryCoreFunctions
 * @notice IDictionaryCoreFunctions is an interface that defines the functions for the Dictionary contract.
 */
interface IDictionaryCoreFunctions {
    // ============================================== //
    //              EXTERNAL READ FUNCTIONS           //
    // ============================================== //

    /**
     * @notice get implementation address by function selector
     * @param selector function selector
     * @return implementation address
     */
    function getImplementation(bytes4 selector) external view returns (address);

    /**
     * @notice get implementation address
     * @return implementation address
     */
    function implementation() external view returns (address);

    /**
     * @notice check if the interface is supported
     * @param interfaceId interface id
     * @return true if the interface is supported, false otherwise
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    /**
     * @notice get all supported interfaces
     * @return all supported interfaces
     */
    function supportsInterfaces() external view returns (bytes4[] memory);
}
