// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IDictionaryCore} from "../interfaces/IDictionaryCore/IDictionaryCore.sol";
import {IDictionary} from "../interfaces/IDictionary/IDictionary.sol";

/**
 * @title DictionaryFacade
 * @notice DictionaryFacade is a proxy contract for the Dictionary contract.
 */
contract DictionaryFacade is IDictionaryCore, IDictionary {
    // ============================================== //
    //              EXTERNAL WRITE FUNCTIONS          //
    // ============================================== //

    function setImplementation(
        bytes4 selector,
        address implementation_
    ) external override {}

    function bulkSetImplementation(
        bytes4[] memory selectors,
        address implementation_
    ) external override {}

    function bulkSetImplementation(
        bytes4[] memory selectors,
        address[] memory implementations
    ) external override {}

    function upgradeFacade(address newFacade) external override {}

    function setOnceInitialized(
        address account,
        address implementation_
    ) external override {}

    // ============================================== //
    //              EXTERNAL READ FUNCTIONS           //
    // ============================================== //

    function getFacade() external view override returns (address) {}

    function getImplementation(
        bytes4 selector
    ) external view override returns (address) {}

    function implementation() external view override returns (address) {}

    function supportsInterface(
        bytes4 interfaceId
    ) external view virtual override returns (bool) {}

    function supportsInterfaces() external view override returns (bytes4[] memory) {}
}