// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Schema as DictionarySchema} from "../storages/Schema.sol";
import {Storage as DictionaryStorage} from "../storages/Storage.sol";

// interfaces
import {IDictionaryCoreEvents} from "../interfaces/IDictionaryCore/IDictionaryCoreEvents.sol";
import {IDictionaryCoreErrors} from "../interfaces/IDictionaryCore/IDictionaryCoreErrors.sol";
import {IVerifiable} from "../interfaces/IVerifiable.sol";

/**
 * @title DictionaryCoreLib
 * @notice DictionaryCoreLib is a library for the Dictionary contract.
 */
library DictionaryCoreLib {
    // ============================================== //
    //              INTERNAL WRITE FUNCTIONS          //
    // ============================================== //

    /**
     * @dev set implementation address
     * @param selector function selector
     * @param impl implementation address
     */
    function setImplementation(bytes4 selector, address impl) internal {
        if (impl == address(0)) {
            __deleteImplementation(selector);
            return;
        }

        __updateFunctionSelectorList(selector);
        __updateImplementation(selector, impl);
    }

    /**
     * @dev upgrade facade
     * @param newFacade new facade address
     */
    function upgradeFacade(address newFacade) internal {
        DictionaryStorage.DictionaryBaseSlot().facade = newFacade;
        emit IVerifiable.FacadeUpgraded(newFacade);
    }

    // ============================================== //
    //              INTERNAL READ FUNCTIONS           //
    // ============================================== //

    function getImplementation(
        bytes4 selector
    ) internal view returns (address) {
        return _getImplementation(selector);
    }

    function implementation() internal view returns (address) {
        return DictionaryStorage.DictionaryBaseSlot().facade;
    }

    function supportsInterface(
        bytes4 interfaceId
    ) internal view returns (bool) {
        return _supportsInterface(interfaceId);
    }

    function supportsInterfaces() internal view returns (bytes4[] memory) {
        DictionarySchema.DictionaryBaseLayout storage $ = DictionaryStorage
            .DictionaryBaseSlot();
        return $.functionSelectorList;
    }

    // ============================================== //
    //             INTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    /**
     * @dev delete implementation address
     * @param selector function selector
     */
    function __deleteImplementation(bytes4 selector) internal {
        DictionarySchema.DictionaryBaseLayout storage $ = DictionaryStorage
            .DictionaryBaseSlot();
        for (uint i; i < $.functionSelectorList.length; ++i) {
            if ($.functionSelectorList[i] == selector) {
                delete $.functionSelectorList[i];
                break;
            }
        }
        delete $.functions[selector];
        emit IDictionaryCoreEvents.ImplementationDeleted(selector);
    }

    /**
     * @dev update function selector list
     * @param selector function selector
     */
    function __updateFunctionSelectorList(bytes4 selector) internal {
        if (__existsSameSelector(selector)) return;
        DictionaryStorage.DictionaryBaseSlot().functionSelectorList.push(
            selector
        );
        emit IDictionaryCoreEvents.NewFunctionSelectorAdded(selector);
    }

    /**
     * @dev check if the function selector exists
     * @param selector function selector
     * @return true if the function selector exists, false otherwise
     */
    function __existsSameSelector(bytes4 selector) internal view returns (bool) {
        DictionarySchema.DictionaryBaseLayout storage $ = DictionaryStorage
            .DictionaryBaseSlot();
        for (uint i; i < $.functionSelectorList.length; ++i) {
            if ($.functionSelectorList[i] == selector) return true;
        }
        return false;
    }

    /**
     * @dev update implementation address
     * @param selector function selector
     * @param impl implementation address
     */
    function __updateImplementation(bytes4 selector, address impl) internal {
        if (impl.code.length == 0)
            revert IDictionaryCoreErrors.InvalidImplementation(impl);
        DictionaryStorage.DictionaryBaseSlot().functions[selector] = impl;
        emit IDictionaryCoreEvents.ImplementationUpgraded(selector, impl);
    }

    // ============================================== //
    //              INTERNAL READ FUNCTIONS           //
    // ============================================== //

    /**
     * @dev get implementation address by function selector
     * @param selector function selector
     * @return implementation address
     */
    function _getImplementation(
        bytes4 selector
    ) internal view returns (address) {
        DictionarySchema.DictionaryBaseLayout storage $ = DictionaryStorage
            .DictionaryBaseSlot();
        address impl = $.functions[selector];
        if (impl != address(0)) return impl;
        impl = $.functions[bytes4(0)];
        if (impl != address(0)) return impl;
        revert IDictionaryCoreErrors.ImplementationNotFound(selector);
    }

    /**
     * @dev check if the contract supports the given interface
     * @param interfaceId equals to the function selector
     * @return true if the contract supports the interface, false otherwise
     */
    function _supportsInterface(
        bytes4 interfaceId
    ) internal view returns (bool) {
        DictionarySchema.DictionaryBaseLayout storage $ = DictionaryStorage
            .DictionaryBaseSlot();
        return $.functions[interfaceId] != address(0);
    }
}
