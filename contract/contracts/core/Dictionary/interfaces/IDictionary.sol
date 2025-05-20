// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IDictionaryCore} from "./IDictionaryCore.sol";

interface IDictionary is IDictionaryCore {
    // ============================================== //
    //                      Errors                     //
    // ============================================== //

    error NotOwnerOrInitialized(address account, address implementation);

    // ============================================== //
    //                External Write Functions        //
    // ============================================== //

    /**
     * @dev set implementation address
     * @param selector function selector
     * @param implementation implementation address
     */
    function setImplementation(bytes4 selector, address implementation) external;

    /**
     * @dev bulk set implementation address
     * @param selectors function selectors
     * @param implementations implementation addresses
     */
    function bulkSetImplementation(bytes4[] memory selectors, address[] memory implementations) external;

    /**
     * @dev upgrade facade
     * @param newFacade new facade address
     */
    function upgradeFacade(address newFacade) external;

    /**
     * @dev set once initialized
     * @param account account address
     * @param implementation implementation address
     */
    function setOnceInitialized(address account, address implementation) external;

    // ============================================== //
    //              External Read Functions           //
    // ============================================== //

    /**
     * @dev get facade address
     * @return facade address
     */
    function getFacade() external view returns (address);
}
