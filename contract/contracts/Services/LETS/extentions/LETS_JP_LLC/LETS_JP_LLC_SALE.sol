// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {LETSSaleBase} from "../../LETSSaleBase.sol";

// upgradeable
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title Legal Embedded Token Sale Contract
contract LETS_JP_LLC_SALE is Initializable, LETSSaleBase {
    // ============================================== //
    //                  Constructor                   //
    // ============================================== //

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ============================================== //
    //                  Initializer                   //
    // ============================================== //

    function initialize(
        address owner,
        address sc,
        bytes memory params
    ) external initializer {
        __LETSSaleBase_init(owner, sc, params);
    }
}
