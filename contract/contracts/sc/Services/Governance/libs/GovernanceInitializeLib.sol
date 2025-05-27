// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Dictionary} from "../../../../core/Dictionary/functions/Dictionary.sol";

// storages
import {Schema as InitializeSchema} from "../../../../core/Initialize/storages/Schema.sol";
import {Storage as InitializeStorage} from "../../../../core/Initialize/storages/Storage.sol";

// interfaces
import {InitializeErrors} from "../../../../core/Initialize/interfaces/InitializeErrors.sol";

/**
 * @title GovernanceInitializeLib
 * @notice Library for initializing the Governance service
 */
library GovernanceInitializeLib {
    // ============================================== //
    //                   EVENTS                       //
    // ============================================== //
    event GovernanceInitialized(address indexed initializer);

    // ============================================== //
    //           EXTERNAL WRITE FUNCTIONS             //
    // ============================================== //

    function initialize(address dictionary) internal {
        InitializeSchema.InitializeLayout storage $init = InitializeStorage
            .InitializeSlot();
        require(!$init.initialized, InitializeErrors.AlreadyInitialized());

        bytes4[] memory selectors = new bytes4[](6);
        selectors[0] = bytes4(keccak256("execute(uint256)"));
        selectors[1] = bytes4(keccak256("approveTransaction(uint256)"));
        selectors[2] = bytes4(
            keccak256(
                "registerTransaction(uint256,bytes,address,address,uint8,uint256,uint256,address[])"
            )
        );
        selectors[3] = bytes4(
            keccak256(
                "registerTransactionWithCustomThreshold(uint256,bytes,address,address,uint8,uint256,uint256,uint256,uint256,address[])"
            )
        );
        selectors[4] = bytes4(keccak256("cancelTransaction(uint256)"));
        selectors[5] = bytes4(keccak256("getTransaction(uint256)"));
        Dictionary(dictionary).bulkSetImplementation(selectors, address(this));
        emit GovernanceInitialized(msg.sender);
    }
}
