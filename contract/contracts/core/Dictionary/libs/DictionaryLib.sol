// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage as DictionaryStorage} from "../storages/Storage.sol";

// libs
import {DictionaryCoreLib} from "./DictionaryCoreLib.sol";

/**
 * @title DictionaryLib
 * @notice DictionaryLib is a library for the Dictionary contract.
 */
library DictionaryLib {
    // ============================================== //
    //              EXTERNAL WRITE FUNCTIONS          //
    // ============================================== //

    function setImplementation(
        bytes4 selector,
        address implementation
    ) internal {
        DictionaryCoreLib.setImplementation(selector, implementation);
    }

    function bulkSetImplementation(
        bytes4[] memory selectors,
        address implementation
    ) internal {
        for (uint256 i = 0; i < selectors.length; i++) {
            DictionaryCoreLib.setImplementation(selectors[i], implementation);
        }
    }

    function bulkSetImplementation(
        bytes4[] memory selectors,
        address[] memory implementations
    ) internal {
        for (uint256 i = 0; i < selectors.length; i++) {
            DictionaryCoreLib.setImplementation(
                selectors[i],
                implementations[i]
            );
        }
    }

    function upgradeFacade(address newFacade) internal {
        DictionaryCoreLib.upgradeFacade(newFacade);
    }

    function setOnceInitialized(
        address account,
        address implementation
    ) internal {
        DictionaryStorage.DictionarySlot().onceInitialized[account][
            implementation
        ] = true;
    }

    // ============================================== //
    //              EXTERNAL READ FUNCTIONS           //
    // ============================================== //

    function getFacade() internal view returns (address) {
        return DictionaryCoreLib.implementation();
    }
}
