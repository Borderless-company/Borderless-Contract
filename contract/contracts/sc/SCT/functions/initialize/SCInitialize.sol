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
 * @title SCInitialize
 * @notice Initialize the SCT contract
 */
contract SCInitialize {
    event InitializeBorderless(address indexed founder);

    function initialize(
        address dictionary,
        address implementation,
        address founder,
        address scr
    ) public {
        InitializeSchema.InitializeLayout storage $initialize = InitializeStorage.InitializeSlot();

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
            .roles[Constants.DEFAULT_ADMIN_ROLE]
            .hasRole[founder] = true;

        AccessControlStorage
            .AccessControlSlot()
            .roles[Constants.FOUNDER_ROLE]
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
        bytes4[] memory selectors = new bytes4[](5);
        selectors[0] = bytes4(keccak256("registerService(uint8[],address[])"));
        selectors[1] = bytes4(
            keccak256("setInvestmentAmount(address,uint256)")
        );
        selectors[2] = bytes4(keccak256("getSCR()"));
        selectors[3] = bytes4(keccak256("getService(uint8)"));
        selectors[4] = bytes4(keccak256("getInvestmentAmount(address)"));
        Dictionary(dictionary).bulkSetImplementation(selectors, implementation);
    }
}
