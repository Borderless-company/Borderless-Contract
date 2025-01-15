// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {LETSBase} from "../../LETSBase.sol";
import {ErrorLETS_JP_LLC_NON_EXE} from "./interfaces/ErrorLETS_JP_LLC_NON_EXE.sol";
// upgradeable
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title Legal Embedded Token Service
contract LETS_JP_LLC_NON_EXE is
    Initializable,
    LETSBase,
    ErrorLETS_JP_LLC_NON_EXE
{
    // ============================================== //
    //                  Storage                   //
    // ============================================== //

    address private _letsNonExeSale;

    // ============================================== //
    //                  Modifier                      //
    // ============================================== //

    modifier onlyLetsNonExeSaleOrGovernanceOrTokenMintRole() {
        require(
            _letsNonExeSale == msg.sender ||
                msg.sender == _governance ||
                _sc.hasRole(_sc.TOKEN_MINT_ROLE(), msg.sender),
            NotLetsNonExeSale(msg.sender)
        );
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

    function initialize(
        address _owner,
        address _register,
        bytes calldata _extraParams
    ) external initializer {
        __LETSBase_initialize(_owner, _register, _extraParams);
        (, , , , , address letsNonExeSale_) = abi.decode(
            _extraParams,
            (string, string, string, string, address, address)
        );
        _letsNonExeSale = letsNonExeSale_;
    }

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    function mint(
        address to,
        uint256 tokenId
    ) public override onlyLetsNonExeSaleOrGovernanceOrTokenMintRole {
        super.mint(to, tokenId);
    }

    // ============================================== //
    //           ERC721Upgradeable Functions          //
    // ============================================== //

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        if (_ownerOf(tokenId) != address(0)) {
            require(msg.sender == _governance, NotTransferable());
        }
        return _update(to, tokenId, auth);
    }
}
