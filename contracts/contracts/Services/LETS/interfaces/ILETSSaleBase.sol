// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @title feature interface for Legal Embedded Token Service Sale contract
interface ILETSSaleBase {
    // ============================================== //
	//                     Events                     //
	// ============================================== //

    /**
     * @dev token purchase event
     * @param tokenId token id
     * @param to address to
     * @param price price
     */
    event TokenPurchased(uint256 tokenId, address to, uint256 price);

    // ============================================== //
	//                     Errors                     //
	// ============================================== //

    /**
     * @dev Not LETS sale deployer Error
     * @param caller function caller
     */
    error NotLetsSaleDeployer(address caller);

    /**
     * @dev Not sale active Error
     * @param saleStart sale start time
     * @param saleEnd sale end time
     */
    error NotSaleActive(uint256 saleStart, uint256 saleEnd);

    /**
     * @dev Already purchased Error
     * @param caller function caller
     */
    error AlreadyPurchased(address caller);

    /**
     * @dev Insufficient funds Error
     * @param minPrice minimum price
     * @param maxPrice maximum price
     * @param sendValue sent value
     */
    error InsufficientFunds(uint256 minPrice, uint256 maxPrice, uint256 sendValue);

    /**
     * @dev Invalid sale period Error
     */
    error InvalidSalePeriod();

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

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
     * @notice update lets
     * @param lets address
     */
    function updateLets(address lets) external;

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
