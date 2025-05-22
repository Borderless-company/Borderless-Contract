// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// lib
import {Dictionary} from "../../../../../../../../core/Dictionary/Dictionary.sol";

// storage
import {Schema as InitializeSchema} from "../../../../../../../../core/Initialize/storages/Schema.sol";
import {Storage as InitializeStorage} from "../../../../../../../../core/Initialize/storages/Storage.sol";

// interfaces
import {InitializeErrors} from "../../../../../../../../core/Initialize/interfaces/InitializeErrors.sol";

library LETSSaleBaseInitializeLib {
    event LETSSaleBaseInitialized(address indexed initializer);

    function initialize(address dictionary) internal {
        InitializeSchema.InitializeLayout storage $init = InitializeStorage
            .InitializeSlot();
        require(!$init.initialized, InitializeErrors.AlreadyInitialized());
        bytes4[] memory selectors = new bytes4[](2);
        selectors[0] = bytes4(keccak256("initialMint(address[])"));
        selectors[1] = bytes4(
            keccak256("getInitialMintExecuteMemberCompleted()")
        );
        for (uint256 i = 0; i < selectors.length; i++) {
            Dictionary(dictionary).setImplementation(
                selectors[i],
                address(this)
            );
        }
        emit LETSSaleBaseInitialized(msg.sender);
    }
}
