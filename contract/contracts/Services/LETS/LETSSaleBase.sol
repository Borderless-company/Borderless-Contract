// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ILETSSaleBase} from "./interfaces/ILETSSaleBase.sol";
import {ILETSBase} from "./interfaces/ILETSBase.sol";

// lib
import {Constants} from "../../lib/Constants.sol";

// utils
import {IErrors} from "../../utils/IErrors.sol";

// OpenZeppelin
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

contract LETSSaleBase is Initializable, ILETSSaleBase {
    // ============================================== //
    //                  Storage                   //
    // ============================================== //

    address private _scr;
    ILETSBase private _lets;
    uint256 private _saleStart;
    uint256 private _saleEnd;
    uint256 private _fixedPrice;
    uint256 private _minPrice;
    uint256 private _maxPrice;
    bool private _hasSalePeriod;
    bool private _isPriceRange;

    // ============================================== //
    //                   Modifier                     //
    // ============================================== //

    modifier onlyDuringSale() {
        if (_hasSalePeriod) {
            require(
                block.timestamp >= _saleStart && block.timestamp <= _saleEnd,
                NotSaleActive(_saleStart, _saleEnd)
            );
        }
        _;
    }

    modifier onlyTreasuryRole() {
        address sc = _lets.getSC();
        require(
            IAccessControl(sc).hasRole(Constants.TREASURY_ROLE, msg.sender),
            IErrors.NotTreasuryRole(msg.sender)
        );
        _;
    }

    modifier onlySCR() {
        require(msg.sender == _scr, IErrors.NotSCR(msg.sender));
        _;
    }

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

    function __LETSSaleBase_init(
        address,
        address sc,
        bytes memory
    ) internal initializer {
        _scr = sc;
    }

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    function offerToken(address to) external payable override onlyDuringSale {
        require(
            IERC721(address(_lets)).balanceOf(to) == 0,
            AlreadyPurchased(to)
        );
        if (_isPriceRange) {
            require(
                msg.value >= _minPrice && msg.value <= _maxPrice,
                InsufficientFunds(_minPrice, _maxPrice, msg.value)
            );
        } else {
            require(
                msg.value == _fixedPrice,
                InsufficientFunds(_minPrice, _maxPrice, msg.value)
            );
        }

        uint256 tokenId = ILETSBase(_lets).mint(msg.sender);

        emit TokenPurchased(tokenId, msg.sender, msg.value);
    }

    function withdraw() external override onlyTreasuryRole {
        payable(msg.sender).transfer(address(this).balance);
    }

    function updateLets(address lets) external override onlySCR {
        _lets = ILETSBase(lets);
    }

    function updateSalePeriod(
        uint256 saleStart,
        uint256 saleEnd
    ) external onlyTreasuryRole {
        require(saleEnd > saleStart, InvalidSalePeriod());
        _saleStart = saleStart;
        _saleEnd = saleEnd;
    }

    function updateHasSalePeriod(
        bool hasSalePeriod
    ) external override onlyTreasuryRole {
        _hasSalePeriod = hasSalePeriod;
    }

    function updatePrice(
        uint256 fixedPrice,
        uint256 minPrice,
        uint256 maxPrice
    ) external onlyTreasuryRole {
        _fixedPrice = fixedPrice;
        _minPrice = minPrice;
        _maxPrice = maxPrice;
    }

    function updateIsPriceRange(
        bool isPriceRange
    ) external override onlyTreasuryRole {
        _isPriceRange = isPriceRange;
    }
}
