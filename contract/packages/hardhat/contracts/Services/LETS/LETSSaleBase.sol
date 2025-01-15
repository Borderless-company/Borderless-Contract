// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

// interfaces
import {ILETSSaleBase} from "./interfaces/ILETSSaleBase.sol";
import {ErrorLETSSaleBase} from "./interfaces/ErrorLETSSaleBase.sol";
import {EventLETSSaleBase} from "./interfaces/EventLETSSaleBase.sol";
import {ILETSBase} from "./interfaces/ILETSBase.sol";

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

// upgradeable
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract LETSSaleBase is
    Initializable,
    ILETSSaleBase,
    ErrorLETSSaleBase,
    EventLETSSaleBase
{
    // ============================================== //
    //                  Storage                   //
    // ============================================== //

    address private _deployer;
    address public _letsNonExe;
    uint256 public _nextTokenId;
    uint256 public saleStart;
    uint256 public saleEnd;
    uint256 public fixedPrice;
    uint256 public minPrice;
    uint256 public maxPrice;
    bool public hasSalePeriod;
    bool public isPriceRange;

    // ============================================== //
    //                   Modifier                     //
    // ============================================== //

    modifier onlyDuringSale() {
        if (hasSalePeriod) {
            require(
                block.timestamp >= saleStart && block.timestamp <= saleEnd,
                NotSaleActive(saleStart, saleEnd)
            );
        }
        _;
    }

    modifier onlyDeployer() {
        require(msg.sender == _deployer, NotLetsSaleDeployer(msg.sender));
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
        address letsNonExe,
        uint256 _saleStart,
        uint256 _saleEnd,
        uint256 _fixedPrice,
        uint256 _minPrice,
        uint256 _maxPrice,
        bool _hasSalePeriod,
        bool _isPriceRange
    ) internal initializer {
        _letsNonExe = letsNonExe;
        saleStart = _saleStart;
        saleEnd = _saleEnd;
        fixedPrice = _fixedPrice;
        minPrice = _minPrice;
        maxPrice = _maxPrice;
        hasSalePeriod = _hasSalePeriod;
        isPriceRange = _isPriceRange;
    }

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    function buyToken() external payable override onlyDuringSale {
        require(
            IERC721(_letsNonExe).balanceOf(msg.sender) == 0,
            AlreadyPurchased(msg.sender)
        );
        if (isPriceRange) {
            require(
                msg.value >= minPrice && msg.value <= maxPrice,
                InsufficientFunds(minPrice, maxPrice, msg.value)
            );
        } else {
            require(
                msg.value == fixedPrice,
                InsufficientFunds(minPrice, maxPrice, msg.value)
            );
        }

        uint256 tokenId = ++_nextTokenId;
        ILETSBase(_letsNonExe).mint(msg.sender, tokenId);

        emit TokenPurchased(tokenId, msg.sender, msg.value);
    }

    function withdraw() external override onlyDeployer {
        payable(_deployer).transfer(address(this).balance);
    }

    function updateSalePeriod(
        uint256 _saleStart,
        uint256 _saleEnd
    ) external onlyDeployer {
        require(_saleEnd > _saleStart, InvalidSalePeriod());
        saleStart = _saleStart;
        saleEnd = _saleEnd;
    }

    function updateHasSalePeriod(
        bool _hasSalePeriod
    ) external override onlyDeployer {
        hasSalePeriod = _hasSalePeriod;
    }

    function updatePrice(
        uint256 _fixedPrice,
        uint256 _minPrice,
        uint256 _maxPrice
    ) external onlyDeployer {
        fixedPrice = _fixedPrice;
        minPrice = _minPrice;
        maxPrice = _maxPrice;
    }

    function updateIsPriceRange(
        bool _isPriceRange
    ) external override onlyDeployer {
        isPriceRange = _isPriceRange;
    }
}
