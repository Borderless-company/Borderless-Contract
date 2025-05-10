// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Schema} from "../storages/Schema.sol";
import {Storage} from "../storages/Storage.sol";
import {Storage as AccessControlStorage} from "../../BorderlessAccessControl/storages/Storage.sol";
import {Constants} from "../../lib/Constants.sol";

contract Initialize {
    event InitializeBorderless(address indexed defaultAdmin);

    function initialize(address defaultAdmin) external {
        Schema.InitializeLayout storage $initialize = Storage.InitializeSlot();
        // check if already initialized
        require(!$initialize.initialized, "Already initialized");
        // set initialized
        $initialize.initialized = true;

        // grant default admin role
        AccessControlStorage
            .AccessControlSlot()
            ._roles[Constants.DEFAULT_ADMIN_ROLE]
            .hasRole[defaultAdmin] = true;

        emit InitializeBorderless(defaultAdmin);
    }
}
