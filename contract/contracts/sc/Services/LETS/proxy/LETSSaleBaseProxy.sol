// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {ILETSSaleBase} from "../interfaces/ILETSSaleBase.sol";

/**
 * @title LETSSaleBaseProxy
 * @notice Proxy contract for the LETSSaleBase contract
 */
contract LETSSaleBaseProxy is ILETSSaleBase {
    // ============================================== //
    //             EXTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    function initialize(address dictionary) external override {}

    function setSaleInfo(
        uint256 saleStart,
        uint256 saleEnd,
        uint256 fixedPrice,
        uint256 minPrice,
        uint256 maxPrice
    ) external override {}

    function offerToken(address to) external payable override {}

    function withdraw() external override {}

    function updateSalePeriod(
        uint256 _saleStart,
        uint256 _saleEnd
    ) external override {}

    function updatePrice(
        uint256 _fixedPrice,
        uint256 _minPrice,
        uint256 _maxPrice
    ) external override {}
}
