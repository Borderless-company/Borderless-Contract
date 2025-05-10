// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {LETSBase} from "../../LETSBase.sol";
import {ErrorLETS_JP_LLC_NON_EXE} from "./interfaces/ErrorLETS_JP_LLC_NON_EXE.sol";
// upgradeable
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title Non Executable Legal Embedded Token Service
contract LETS_JP_LLC_NON_EXE is
    Initializable,
    LETSBase,
    ErrorLETS_JP_LLC_NON_EXE
{
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
        address owner,
        address sc,
        bytes memory params
    ) external initializer {
        __LETSBase_initialize(owner, sc, params);
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
