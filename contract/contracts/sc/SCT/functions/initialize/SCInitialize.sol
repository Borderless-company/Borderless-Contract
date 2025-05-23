// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Dictionary} from "../../../../core/Dictionary/Dictionary.sol";

// storages
import {Schema} from "../../../../core/Initialize/storages/Schema.sol";
import {Storage} from "../../../../core/Initialize/storages/Storage.sol";
import {Storage as SCTStorage} from "../../storages/Storage.sol";
import {Storage as AccessControlStorage} from "../../../../core/BorderlessAccessControl/storages/Storage.sol";

// lib
import {Constants} from "../../../../core/lib/Constants.sol";

// utils

// interfaces
import {InitializeErrors} from "../../../../core/Initialize/interfaces/InitializeErrors.sol";

contract SCInitialize {
    event InitializeBorderless(address indexed founder);

    function initialize(
        address dictionary,
        address implementation,
        address founder,
        address scr
    ) public {
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

        _registerDictionary(dictionary, implementation);
        emit InitializeBorderless(founder);
    }

    function _registerDictionary(
        address dictionary,
        address implementation
    ) internal {
        bytes4[] memory selectors = new bytes4[](6);
        selectors[0] = bytes4(keccak256("registerService(uint8[],address[])"));
        selectors[1] = bytes4(
            keccak256("setInvestmentAmount(address,uint256)")
        );
        selectors[2] = bytes4(keccak256("getSCR()"));
        selectors[3] = bytes4(keccak256("getFounder()"));
        selectors[4] = bytes4(keccak256("getService(uint8)"));
        selectors[5] = bytes4(keccak256("getInvestmentAmount(address)"));
        Dictionary(dictionary).bulkSetImplementation(selectors, implementation);
    }
}
