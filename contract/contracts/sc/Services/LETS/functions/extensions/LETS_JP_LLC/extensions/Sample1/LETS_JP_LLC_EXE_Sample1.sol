// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {LETS_JP_LLC_EXE} from "../../LETS_JP_LLC_EXE.sol";

// storage
import {Storage as LETSBaseStorage} from "../../../../../storages/Storage.sol";

// lib
import {LETS_JP_LLC_EXEInitializeLib} from "../../../../../libs/extensions/LETS_JP_LLC/LETS_JP_LLC_EXEInitializeLib.sol";
import {ERC721Lib} from "../../../../../../../ERC721/libs/ERC721Lib.sol";

/**
 * @title Legal Embedded Token Service
 */
contract LETS_JP_LLC_EXE_Sample1 is LETS_JP_LLC_EXE {
    // ============================================== //
    //                Initialization                  //
    // ============================================== //

    error InvalidTokenId(uint256 tokenId);

    // ============================================== //
    //                Initialization                  //
    // ============================================== //

    function initialize(
        address dictionary,
        address implementation,
        address sc,
        bytes calldata params
    ) public override returns (bytes4[] memory selectors) {
        selectors = super.initialize(dictionary, implementation, sc, params);
        LETS_JP_LLC_EXEInitializeLib.initialize(dictionary, selectors, implementation);
        (uint256 baseTokenId) = abi.decode(params, (uint256));
        LETSBaseStorage.LETSBaseSlot().nextTokenId = baseTokenId;
    }

    // ============================================== //
    //             Eternal Write Functions            //
    // ============================================== //

    function mint(address to, uint256 tokenId) external {
        require(tokenId <= 708, InvalidTokenId(tokenId));
        ERC721Lib.safeMint(to, tokenId);
    }
}
