// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {LETSSaleBase} from "../../LETSSaleBase.sol";

// upgradeable
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title Legal Embedded Token Non-Execution Sale Contract
contract LETS_JP_LLC_NON_EXE_SALE is Initializable, LETSSaleBase {
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

    function initialize(bytes calldata _extraParams) external initializer {
        (
            address letsNonExe,
            uint256 _saleStart,
            uint256 _saleEnd,
            uint256 _fixedPrice,
            uint256 _minPrice,
            uint256 _maxPrice,
            bool _hasSalePeriod,
            bool _isPriceRange
        ) = abi.decode(
                _extraParams,
                (
                    address,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    uint256,
                    bool,
                    bool
                )
            );
        __LETSSaleBase_init(
            letsNonExe,
            _saleStart,
            _saleEnd,
            _fixedPrice,
            _minPrice,
            _maxPrice,
            _hasSalePeriod,
            _isPriceRange
        );
    }
}
