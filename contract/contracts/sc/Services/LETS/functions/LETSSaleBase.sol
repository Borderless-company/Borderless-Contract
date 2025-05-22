// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Schema as LETSSaleBaseSchema} from "../storages/Schema.sol";
import {Storage as LETSSaleBaseStorage} from "../storages/Storage.sol";

// lib
import {Constants} from "../../../../core/lib/Constants.sol";
import {LETSBaseLib} from "../libs/LETSBaseLib.sol";
import {LETSSaleBaseLib} from "../libs/LETSSaleBaseLib.sol";
import {LETSSaleBaseInitializeLib} from "../../../../core/Initialize/libs/LETSSaleBaseInitializeLib.sol";
import {ERC721Lib} from "../../../../sc/ERC721/libs/ERC721Lib.sol";
import {BorderlessAccessControlLib} from "../../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";

// utils
import {IErrors} from "../../../../core/utils/IErrors.sol";

// interfaces
import {ILETSSaleBase} from "../interfaces/ILETSSaleBase.sol";

contract LETSSaleBase is ILETSSaleBase {
    // ============================================== //
    //                 Initialization                 //
    // ============================================== //

    function initialize(address dictionary) external {
        LETSSaleBaseInitializeLib.initialize(dictionary);
    }

    // ============================================== //
    //                   Modifier                     //
    // ============================================== //

    modifier onlySaleActive() {
        LETSSaleBaseSchema.LETSSaleBaseLayout storage $ = LETSSaleBaseStorage
            .LETSSaleBaseSlot();
        require($.isSaleActive, SaleNotActive());
        _;
    }

    modifier onlyDuringSale() {
        LETSSaleBaseSchema.LETSSaleBaseLayout storage $ = LETSSaleBaseStorage
            .LETSSaleBaseSlot();
        if ($.saleStart != 0 && $.saleEnd != 0) {
            require(
                block.timestamp >= $.saleStart && block.timestamp <= $.saleEnd,
                NotSaleActive($.saleStart, $.saleEnd)
            );
        }
        _;
    }

    modifier onlyTreasuryRole() {
        require(
            BorderlessAccessControlLib.hasRole(
                Constants.TREASURY_ROLE,
                msg.sender
            ),
            IErrors.NotTreasuryRole(msg.sender)
        );
        _;
    }

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    function setSaleInfo(
        uint256 saleStart,
        uint256 saleEnd,
        uint256 fixedPrice,
        uint256 minPrice,
        uint256 maxPrice
    ) external {
        require(
            BorderlessAccessControlLib.hasRole(
                Constants.DEFAULT_ADMIN_ROLE,
                msg.sender
            ),
            IErrors.NotFounder(msg.sender)
        );
        LETSSaleBaseSchema.LETSSaleBaseLayout storage $ = LETSSaleBaseStorage
            .LETSSaleBaseSlot();
        if ($.saleStart != 0 && $.saleEnd != 0) {
            LETSSaleBaseLib.setSalePeriod(saleStart, saleEnd);
        }
        LETSSaleBaseLib.setPrice(fixedPrice, minPrice, maxPrice);
        $.isSaleActive = true;
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
    ) external onlyTreasuryRole {
        LETSSaleBaseLib.setSalePeriod(saleStart, saleEnd);
    }

    function updatePrice(
        uint256 fixedPrice,
        uint256 minPrice,
        uint256 maxPrice
    ) external onlyTreasuryRole {
        LETSSaleBaseLib.setPrice(fixedPrice, minPrice, maxPrice);
    }
}
