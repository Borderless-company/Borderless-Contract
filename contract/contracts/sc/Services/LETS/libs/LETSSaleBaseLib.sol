// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Schema as LETSSaleBaseSchema} from "../storages/Schema.sol";
import {Storage as LETSSaleBaseStorage} from "../storages/Storage.sol";

// interfaces
import {ILETSSaleBaseErrors} from "../interfaces/ILETSSaleBaseErrors.sol";

library LETSSaleBaseLib {
    function setPrice(
        uint256 fixedPrice,
        uint256 minPrice,
        uint256 maxPrice
    ) internal {
        LETSSaleBaseSchema.LETSSaleBaseLayout storage $ = LETSSaleBaseStorage
            .LETSSaleBaseSlot();
        require(
            (fixedPrice != 0 && minPrice == 0 && maxPrice == 0) ||
                (fixedPrice == 0 && minPrice != 0 && maxPrice != 0),
            ILETSSaleBaseErrors.InvalidPrice(fixedPrice, minPrice, maxPrice)
        );
        if (fixedPrice != 0) {
            $.fixedPrice = fixedPrice;
        } else {
            $.minPrice = minPrice;
            $.maxPrice = maxPrice;
        }
    }

    function setSalePeriod(uint256 saleStart, uint256 saleEnd) internal {
        LETSSaleBaseSchema.LETSSaleBaseLayout storage $ = LETSSaleBaseStorage
            .LETSSaleBaseSlot();
        require(
            saleStart != 0 && saleEnd != 0,
            ILETSSaleBaseErrors.InvalidSalePeriod(block.timestamp, saleStart, saleEnd)
        );
        require(
            saleStart > block.timestamp,
            ILETSSaleBaseErrors.InvalidSalePeriod(block.timestamp, saleStart, saleEnd)
        );
        require(saleStart < saleEnd, ILETSSaleBaseErrors.InvalidSalePeriod(block.timestamp, saleStart, saleEnd));
        $.saleStart = saleStart;
        $.saleEnd = saleEnd;
    }
}
