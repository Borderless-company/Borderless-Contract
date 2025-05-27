// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Dictionary} from "../../../../core/Dictionary/functions/Dictionary.sol";

// storages
import {Schema as InitializeSchema} from "../../../../core/Initialize/storages/Schema.sol";
import {Storage as InitializeStorage} from "../../../../core/Initialize/storages/Storage.sol";
import {Storage as SCTStorage} from "../../storages/Storage.sol";
import {Storage as AccessControlStorage} from "../../../../core/BorderlessAccessControl/storages/Storage.sol";

// lib
import {Constants} from "../../../../core/lib/Constants.sol";

// interfaces
import {InitializeErrors} from "../../../../core/Initialize/interfaces/InitializeErrors.sol";

/**
 * @title DictionaryInitialize
 * @notice Initialize the Dictionary contract
 */
contract DictionaryInitialize {
    event InitializeDictionary(address indexed founder);

    function initialize(address dictionary) public {
        InitializeSchema.InitializeLayout
            storage $initialize = InitializeStorage.InitializeSlot();

        // check if already initialized
        require(!$initialize.initialized, "Already initialized");
        // set initialized
        $initialize.initialized = true;

        bytes4[] memory selectors = new bytes4[](10);
        selectors[0] = bytes4(keccak256("setImplementation(bytes4,address)"));
        selectors[1] = bytes4(
            keccak256("bulkSetImplementation(bytes4[],address)")
        );
        selectors[2] = bytes4(
            keccak256("bulkSetImplementation(bytes4[],address[])")
        );
        selectors[3] = bytes4(keccak256("upgradeFacade(address)"));
        selectors[4] = bytes4(keccak256("setOnceInitialized(address,address)"));
        selectors[5] = bytes4(keccak256("getFacade()"));
        selectors[6] = bytes4(keccak256("getImplementation(bytes4)"));
        selectors[7] = bytes4(keccak256("implementation()"));
        selectors[8] = bytes4(keccak256("supportsInterface(bytes4)"));
        selectors[9] = bytes4(keccak256("supportsInterfaces()"));

        Dictionary(dictionary).bulkSetImplementation(selectors, dictionary);
    }
}
