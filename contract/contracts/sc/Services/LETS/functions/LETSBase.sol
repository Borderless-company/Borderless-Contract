// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC721} from "../../../ERC721/functions/ERC721.sol";

// lib
import {LETSBaseLib} from "../libs/LETSBaseLib.sol";
import {LETSBaseInitializeLib} from "../../../../core/Initialize/libs/LETSBaseInitializeLib.sol";

// interfaces
import {ILETSBase} from "../interfaces/ILETSBase.sol";

/**
 * @title Legal Embedded Token Service
 * @notice This contract is used to create a legal embedded token service.
 */
contract LETSBase is ERC721, ILETSBase {
    // ============================================== //
    //                Initialization                  //
    // ============================================== //

    function initialize(address dictionary) external {
        LETSBaseInitializeLib.initialize(dictionary);
    }
    // ============================================== //
    //             Eternal Write Functions            //
    // ============================================== //

    function mint(address to) external override returns (uint256 tokenId) {
        tokenId = LETSBaseLib.mint(to);
    }

    function freezeToken(uint256 tokenId) external override {
        LETSBaseLib.freezeToken(tokenId);
    }

    function unfreezeToken(uint256 tokenId) external override {
        LETSBaseLib.unfreezeToken(tokenId);
    }

    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) public view override returns (uint256) {
        return super.tokenOfOwnerByIndex(owner, index);
    }

    // ============================================== //
    //             Eternal Read Functions             //
    // ============================================== //

    function getUpdatedToken(uint256 tokenId) external view returns (uint256) {
        return LETSBaseLib.getUpdatedToken(tokenId);
    }
}
