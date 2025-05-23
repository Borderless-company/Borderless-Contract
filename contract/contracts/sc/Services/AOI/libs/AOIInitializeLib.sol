// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Dictionary} from "../../../../core/Dictionary/Dictionary.sol";

// storages
import {Schema as InitializeSchema} from "../../../../core/Initialize/storages/Schema.sol";
import {Storage as InitializeStorage} from "../../../../core/Initialize/storages/Storage.sol";

// interfaces
import {InitializeErrors} from "../../../../core/Initialize/interfaces/InitializeErrors.sol";

library AOIInitializeLib {
    event AOIInitialized(address indexed initializer);

    function initialize(address dictionary) internal {
        InitializeSchema.InitializeLayout storage $init = InitializeStorage
            .InitializeSlot();
        require(!$init.initialized, InitializeErrors.AlreadyInitialized());

        bytes4[] memory selectors = new bytes4[](7);
        selectors[0] = bytes4(
            keccak256(
                "initialSetChapter((uint256,uint256,uint256,bytes32,bytes32,bytes32)[]"
            )
        );
        selectors[1] = bytes4(keccak256("setEphemeralSalt(bytes32)"));
        selectors[2] = bytes4(
            keccak256("getEncryptedItem((uint256,uint256,uint256))")
        );
        selectors[3] = bytes4(keccak256("getVersionRoot(uint256)"));
        selectors[4] = bytes4(keccak256("isEphemeralSaltUsed(bytes32)"));
        selectors[5] = bytes4(
            keccak256(
                "verifyDecryptionKeyHash((uint256,uint256,uint256),bytes32)"
            )
        );
        selectors[6] = bytes4(
            keccak256(
                "verifyDecryptionKeyHashWithSaltHash((uint256,uint256,uint256),bytes32,bytes32,address)"
            )
        );
        for (uint256 i = 0; i < selectors.length; i++) {
            Dictionary(dictionary).setImplementation(
                selectors[i],
                address(this)
            );
        }
        emit AOIInitialized(msg.sender);
    }
}
