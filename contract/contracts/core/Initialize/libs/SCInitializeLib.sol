// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Dictionary} from "../../Dictionary/Dictionary.sol";

// storages
import {Schema} from "../storages/Schema.sol";
import {Storage} from "../storages/Storage.sol";
import {Storage as SCTStorage} from "../../../sc/SCT/storages/Storage.sol";
import {Storage as AccessControlStorage} from "../../BorderlessAccessControl/storages/Storage.sol";

// lib
import {Constants} from "../../lib/Constants.sol";

// utils
import {ServiceType} from "../../../core/utils/ITypes.sol";

// interfaces
import {InitializeErrors} from "../interfaces/InitializeErrors.sol";

library SCInitializeLib {
    event InitializeBorderless(address indexed founder);

    function initialize(address founder, address scr) internal {
        Schema.InitializeLayout storage $initialize = Storage.InitializeSlot();
        // check if already initialized
        require(
            !$initialize.initialized,
            InitializeErrors.AlreadyInitialized()
        );
        // set initialized
        $initialize.initialized = true;

        // grant default admin role
        AccessControlStorage
            .AccessControlSlot()
            ._roles[Constants.DEFAULT_ADMIN_ROLE]
            .hasRole[founder] = true;

        AccessControlStorage
            .AccessControlSlot()
            ._roles[Constants.FOUNDER_ROLE]
            .hasRole[founder] = true;

        // set scr address
        SCTStorage.SCTSlot().scr = scr;

        // _registerDictionary(dictionary);
    }

    function _registerDictionary(address dictionary) internal {
        bytes4[] memory selectors = new bytes4[](5);
        selectors[0] = bytes4(keccak256("registerService(uint8[],address[])"));
        selectors[1] = bytes4(
            keccak256("setInvestmentAmount(address,uint256)")
        );
        selectors[2] = bytes4(keccak256("getSCR()"));
        selectors[3] = bytes4(keccak256("getService(uint8)"));
        selectors[4] = bytes4(keccak256("getInvestmentAmount(address)"));
        for (uint256 i = 0; i < selectors.length; i++) {
            Dictionary(dictionary).setImplementation(
                selectors[i],
                address(this)
            );
        }
    }
}
