// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// lib
import {Dictionary} from "../../../../../../core/Dictionary/functions/Dictionary.sol";

// storage
import {Schema as InitializeSchema} from "../../../../../../core/Initialize/storages/Schema.sol";
import {Storage as InitializeStorage} from "../../../../../../core/Initialize/storages/Storage.sol";

// interfaces
import {InitializeErrors} from "../../../../../../core/Initialize/interfaces/InitializeErrors.sol";

library LETS_JP_LLC_NON_EXEInitializeLib {
    event LETS_JP_LLC_NON_EXEInitialized(address indexed initializer);

    function initialize(address dictionary, bytes4[] memory selectors, address implementation) internal {
        InitializeSchema.InitializeLayout storage $init = InitializeStorage
            .InitializeSlot();
        require(!$init.initialized, InitializeErrors.AlreadyInitialized());
        Dictionary(dictionary).bulkSetImplementation(
            selectors,
            implementation
        );
        emit LETS_JP_LLC_NON_EXEInitialized(msg.sender);
    }
}
