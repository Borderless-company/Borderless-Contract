// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ILETSSaleBaseFunctions {
    // ============================================== //
    //             EXTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    /**
     * @notice initialize
     * @param dictionary dictionary address
     */
    function initialize(address dictionary) external;

    /**
     * @notice set sale info
     * @param saleStart sale start time
     * @param saleEnd sale end time
     * @param fixedPrice fixed price
     * @param minPrice minimum price
     * @param maxPrice maximum price
     */
    function setSaleInfo(
        uint256 saleStart,
        uint256 saleEnd,
        uint256 fixedPrice,
        uint256 minPrice,
        uint256 maxPrice
    ) external;

    /**
     * @notice buy token
     * @param to address to
     */
    function offerToken(address to) external payable;

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
     * @notice update price
     * @param _fixedPrice fixed price
     * @param _minPrice minimum price
     * @param _maxPrice maximum price
     */
    function updatePrice(
        uint256 _fixedPrice,
        uint256 _minPrice,
        uint256 _maxPrice
    ) external;
}
