// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// lib
import {Dictionary} from "../../Dictionary/Dictionary.sol";

// storage
import {Schema as InitializeSchema} from "../storages/Schema.sol";
import {Storage as InitializeStorage} from "../storages/Storage.sol";

// interfaces
import {InitializeErrors} from "../interfaces/InitializeErrors.sol";

library LETSSaleBaseInitializeLib {
    event LETSSaleBaseInitialized(address indexed initializer);

    function initialize(address dictionary) internal {
        InitializeSchema.InitializeLayout storage $init = InitializeStorage
            .InitializeSlot();
        require(!$init.initialized, InitializeErrors.AlreadyInitialized());
        bytes4[] memory selectors = new bytes4[](7);
        selectors[0] = bytes4(keccak256("setSaleInfo(uint256,uint256,uint256,uint256,uint256)"));
        selectors[1] = bytes4(keccak256("offerToken(address)"));
        selectors[2] = bytes4(keccak256("withdraw()"));
        selectors[3] = bytes4(keccak256("updateSalePeriod(uint256,uint256)"));
        selectors[4] = bytes4(keccak256("updateHasSalePeriod(bool)"));
        selectors[5] = bytes4(
            keccak256("updatePrice(uint256,uint256,uint256)")
        );
        selectors[6] = bytes4(keccak256("updateIsPriceRange(bool)"));
        for (uint256 i = 0; i < selectors.length; i++) {
            Dictionary(dictionary).setImplementation(
                selectors[i],
                address(this)
            );
        }
        emit LETSSaleBaseInitialized(msg.sender);
    }
}
