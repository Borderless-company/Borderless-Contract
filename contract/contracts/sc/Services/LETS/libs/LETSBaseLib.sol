// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage as LETSBaseStorage} from "../storages/Storage.sol";
import {Storage as ERC721Storage} from "../../../ERC721/storages/Storage.sol";

// lib
import {ERC721Lib} from "../../../ERC721/libs/ERC721Lib.sol";

// interfaces
import {ILETSBase, ILETSBaseEvents} from "../interfaces/ILETSBase.sol";

/**
 * @title Legal Embedded Token Service
 * @notice This contract is used to create a legal embedded token service.
 */
library LETSBaseLib {
    // ============================================== //
    //             Internal Write Functions           //
    // ============================================== //

    function mint(address to) internal returns (uint256 tokenId) {
        tokenId = ++LETSBaseStorage.LETSBaseSlot().nextTokenId;
        ERC721Lib.safeMint(to, tokenId);
    }

    function freezeToken(uint256 tokenId) internal {
        LETSBaseStorage.LETSBaseSlot().freezeToken[tokenId] = true;
        emit ILETSBaseEvents.TokenFrozen(tokenId);
    }

    function unfreezeToken(uint256 tokenId) internal {
        LETSBaseStorage.LETSBaseSlot().freezeToken[tokenId] = false;
        emit ILETSBaseEvents.TokenUnfrozen(tokenId);
    }

    function _increaseBalance(address account, uint128 amount) internal {
        ERC721Storage.ERC721Slot().balances[account] += amount;
    }

    // ============================================== //
    //             Internal Read Functions            //
    // ============================================== //

    function getUpdatedToken(uint256 tokenId) internal view returns (uint256) {
        return LETSBaseStorage.LETSBaseSlot().updatedToken[tokenId];
    }
}
