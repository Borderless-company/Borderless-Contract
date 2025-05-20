// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Dictionary} from "../../Dictionary/Dictionary.sol";

// storages
import {Schema as InitializeSchema} from "../storages/Schema.sol";
import {Storage as InitializeStorage} from "../storages/Storage.sol";

// interfaces
import {InitializeErrors} from "../interfaces/InitializeErrors.sol";

library BorderlessAccessControlInitializeLib {
    event BorderlessAccessControlInitialized(address indexed initializer);

    function initialize(address dictionary) internal {
        InitializeSchema.InitializeLayout storage $init = InitializeStorage
            .InitializeSlot();
        require(!$init.initialized, InitializeErrors.AlreadyInitialized());

        bytes4[] memory selectors = new bytes4[](6);
        selectors[0] = bytes4(keccak256("supportsInterface(bytes4)"));
        selectors[1] = bytes4(keccak256("grantRole(bytes32,address)"));
        selectors[2] = bytes4(keccak256("revokeRole(bytes32,address)"));
        selectors[3] = bytes4(keccak256("renounceRole(bytes32,address)"));
        selectors[4] = bytes4(keccak256("getRoleAdmin(bytes32)"));
        selectors[5] = bytes4(keccak256("hasRole(bytes32,address)"));

        for (uint256 i = 0; i < selectors.length; i++) {
            Dictionary(dictionary).setImplementation(
                selectors[i],
                address(this)
            );
        }
        emit BorderlessAccessControlInitialized(msg.sender);
    }
}

