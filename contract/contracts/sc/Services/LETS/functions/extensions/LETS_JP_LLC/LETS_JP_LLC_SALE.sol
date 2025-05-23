// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {LETSSaleBase} from "../../LETSSaleBase.sol";

/// @title Legal Embedded Token Sale Contract
contract LETS_JP_LLC_SALE is LETSSaleBase {
    // ============================================== //
    //                 Initialization                 //
    // ============================================== //

    function initialize(address dictionary) public override {
        super.initialize(dictionary);
    }
}
