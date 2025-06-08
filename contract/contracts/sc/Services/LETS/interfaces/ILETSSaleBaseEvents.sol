// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ILETSSaleBaseEvents {
    /**
     * @dev token purchase event
     * @param tokenId token id
     * @param to address to
     * @param price price
     */
    event TokenPurchased(uint256 tokenId, address to, uint256 price);

    /**
     * @dev sale info updated event
     * @param saleStart sale start time
     * @param saleEnd sale end time
     * @param fixedPrice fixed price
     * @param minPrice minimum price
     * @param maxPrice maximum price
     */
    event SaleInfoUpdated(uint256 saleStart, uint256 saleEnd, uint256 fixedPrice, uint256 minPrice, uint256 maxPrice);

    /**
     * @dev sale period updated event
     * @param saleStart sale start time
     * @param saleEnd sale end time
     */
    event SalePeriodUpdated(uint256 saleStart, uint256 saleEnd);

    /**
     * @dev price updated event
     * @param fixedPrice fixed price
     * @param minPrice minimum price
     * @param maxPrice maximum price
     */
    event PriceUpdated(uint256 fixedPrice, uint256 minPrice, uint256 maxPrice);
}
