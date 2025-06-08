// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Schema as LETSSaleBaseSchema} from "../storages/Schema.sol";
import {Storage as LETSSaleBaseStorage} from "../storages/Storage.sol";
import {Storage as LETSBaseStorage} from "../storages/Storage.sol";

// lib
import {Constants} from "../../../../core/lib/Constants.sol";
import {LETSBaseLib} from "../libs/LETSBaseLib.sol";
import {LETSSaleBaseLib} from "../libs/LETSSaleBaseLib.sol";
import {LETSSaleBaseInitializeLib} from "../libs/initialize/LETSSaleBaseInitializeLib.sol";
import {ERC721Lib} from "../../../../sc/ERC721/libs/ERC721Lib.sol";

// utils
import {IErrors} from "../../../../core/utils/IErrors.sol";

// interfaces
import {ILETSSaleBase} from "../interfaces/ILETSSaleBase.sol";

// OpenZeppelin
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

/**
 * @title LETSSaleBase
 * @notice This contract is used to manage the sale of the LETS token
 */
contract LETSSaleBase is ILETSSaleBase {
    // ============================================== //
    //                    INITIALIZE                  //
    // ============================================== //

    function initialize(address dictionary) public virtual override {
        LETSSaleBaseInitializeLib.initialize(dictionary);
    }

    // ============================================== //
    //                   MODIFIER                     //
    // ============================================== //

    modifier onlySaleActive() {
        LETSSaleBaseSchema.LETSSaleBaseLayout storage $ = LETSSaleBaseStorage
            .LETSSaleBaseSlot();
        require(
            $.isSaleActive,
            NotSaleActive(
                block.timestamp,
                $.saleStart != 0 ? $.saleStart : 0,
                $.saleEnd != 0 ? $.saleEnd : 0
            )
        );
        _;
    }

    modifier onlyDuringSale() {
        LETSSaleBaseSchema.LETSSaleBaseLayout storage $ = LETSSaleBaseStorage
            .LETSSaleBaseSlot();
        if ($.saleStart != 0 && $.saleEnd != 0) {
            require(
                block.timestamp >= $.saleStart && block.timestamp <= $.saleEnd,
                NotSaleActive(block.timestamp, $.saleStart, $.saleEnd)
            );
        }
        _;
    }

    modifier onlyTreasuryRole() {
        require(
            IAccessControl(LETSBaseStorage.LETSBaseSlot().sc).hasRole(
                Constants.TREASURY_ROLE,
                msg.sender
            ),
            IErrors.NotTreasuryRole(msg.sender)
        );
        _;
    }

    // ============================================== //
    //             EXTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    function setSaleInfo(
        uint256 saleStart,
        uint256 saleEnd,
        uint256 fixedPrice,
        uint256 minPrice,
        uint256 maxPrice
    ) external override {
        require(
            IAccessControl(LETSBaseStorage.LETSBaseSlot().sc).hasRole(
                Constants.FOUNDER_ROLE,
                msg.sender
            ),
            IErrors.NotFounder(msg.sender)
        );
        if (saleStart != 0 && saleEnd != 0) {
            LETSSaleBaseLib.setSalePeriod(saleStart, saleEnd);
        }
        LETSSaleBaseLib.setPrice(fixedPrice, minPrice, maxPrice);
        LETSSaleBaseStorage.LETSSaleBaseSlot().isSaleActive = true;
        emit SaleInfoUpdated(
            saleStart,
            saleEnd,
            fixedPrice,
            minPrice,
            maxPrice
        );
    }

    function offerToken(
        address to
    ) external payable override onlyDuringSale onlySaleActive {
        LETSSaleBaseSchema.LETSSaleBaseLayout storage $ = LETSSaleBaseStorage
            .LETSSaleBaseSlot();
        require(ERC721Lib.balanceOf(to) == 0, AlreadyPurchased(to));
        if ($.minPrice != 0 && $.maxPrice != 0) {
            require(
                msg.value >= $.minPrice && msg.value <= $.maxPrice,
                InsufficientFunds($.minPrice, $.maxPrice, msg.value)
            );
        } else {
            require(
                msg.value == $.fixedPrice,
                InsufficientFunds($.fixedPrice, $.fixedPrice, msg.value)
            );
        }

        uint256 tokenId = LETSBaseLib.mint(msg.sender);

        emit TokenPurchased(tokenId, msg.sender, msg.value);
    }

    function withdraw() external override onlyTreasuryRole {
        payable(msg.sender).transfer(address(this).balance);
    }

    function updateSalePeriod(
        uint256 saleStart,
        uint256 saleEnd
    ) external override onlyTreasuryRole {
        LETSSaleBaseLib.setSalePeriod(saleStart, saleEnd);
        emit SalePeriodUpdated(saleStart, saleEnd);
    }

    function updatePrice(
        uint256 fixedPrice,
        uint256 minPrice,
        uint256 maxPrice
    ) external override onlyTreasuryRole {
        LETSSaleBaseLib.setPrice(fixedPrice, minPrice, maxPrice);
        emit PriceUpdated(fixedPrice, minPrice, maxPrice);
    }
}
