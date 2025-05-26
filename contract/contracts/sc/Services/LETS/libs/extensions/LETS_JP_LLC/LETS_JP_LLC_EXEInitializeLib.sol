// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// lib
import {Dictionary} from "../../../../../../core/Dictionary/Dictionary.sol";

// storage
import {Schema as InitializeSchema} from "../../../../../../core/Initialize/storages/Schema.sol";
import {Storage as InitializeStorage} from "../../../../../../core/Initialize/storages/Storage.sol";

// interfaces
import {InitializeErrors} from "../../../../../../core/Initialize/interfaces/InitializeErrors.sol";

library LETS_JP_LLC_EXEInitializeLib {
    event LETS_JP_LLC_EXEInitialized(address indexed initializer);

    function initialize(address dictionary, bytes4[] memory selectors, address implementation) internal {
        InitializeSchema.InitializeLayout storage $init = InitializeStorage
            .InitializeSlot();
        require(!$init.initialized, InitializeErrors.AlreadyInitialized());
        bytes4[] memory newSelectors = new bytes4[](selectors.length + 2);
        for (uint256 i = 0; i < selectors.length; i++) {
            newSelectors[i] = selectors[i];
        }
        newSelectors[selectors.length] = bytes4(keccak256("initialMint(address[])"));
        newSelectors[selectors.length + 1] = bytes4(
            keccak256("getInitialMintExecuteMemberCompleted()")
        );
        Dictionary(dictionary).bulkSetImplementation(
            newSelectors,
            implementation
        );
        emit LETS_JP_LLC_EXEInitialized(msg.sender);
    }
}
