// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

/// @title feature interface for Legal Embedded Token Service Sale contract
interface ILETSSaleBase {
    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    /**
     * @notice buy token
     */
    function buyToken() external payable;

    /**
     * @notice withdraw ether
     * @dev only deployer
     */
    function withdraw() external;

    /**
     * @notice update sale period
     * @param _saleStart sale start time
     * @param _saleEnd sale end time
     */
    function updateSalePeriod(uint256 _saleStart, uint256 _saleEnd) external;

    /**
     * @notice update has sale period
     * @param _hasSalePeriod has sale period
     */
    function updateHasSalePeriod(bool _hasSalePeriod) external;

    /**
     * @notice update price
     * @param _fixedPrice fixed price
     * @param _minPrice minimum price
     * @param _maxPrice maximum price
     */
    function updatePrice(uint256 _fixedPrice, uint256 _minPrice, uint256 _maxPrice) external;

    /**
     * @notice update is price range
     * @param _isPriceRange is price range
     */
    function updateIsPriceRange(bool _isPriceRange) external;
}
