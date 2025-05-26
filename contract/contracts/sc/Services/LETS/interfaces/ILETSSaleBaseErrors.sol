// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ILETSSaleBaseErrors {
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
    error InsufficientFunds(
        uint256 minPrice,
        uint256 maxPrice,
        uint256 sendValue
    );

    /**
     * @dev Invalid sale period Error
     */
    error InvalidSalePeriod();

    /**
     * @dev Invalid price Error
     */
    error InvalidPrice();

    /**
     * @dev Sale not active Error
     */
    error SaleNotActive();
}
