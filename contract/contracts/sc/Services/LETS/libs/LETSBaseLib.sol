// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage as LETSBaseStorage} from "../storages/Storage.sol";
import {Storage as ERC721Storage} from "../../../ERC721/storages/Storage.sol";

// lib
import {ERC721Lib} from "../../../ERC721/libs/ERC721Lib.sol";

// interfaces
import {ILETSBase, ILETSBaseEvents} from "../interfaces/ILETSBase.sol";
import {ILETSBaseErrors} from "../interfaces/ILETSBaseErrors.sol";

/**
 * @title Legal Embedded Token Service
 * @notice This contract is used to create a legal embedded token service.
 */
library LETSBaseLib {
    // ============================================== //
    //             INTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    /**
     * @notice Mint a token
     * @param to The address to mint the token to
     * @return tokenId The token ID
     */
    function mint(address to) internal returns (uint256 tokenId) {
        require(
            LETSBaseStorage.LETSBaseSlot().maxSupply == 0 ||
                LETSBaseStorage.LETSBaseSlot().maxSupply >= LETSBaseStorage.LETSBaseSlot().nextTokenId,
            ILETSBaseErrors.MaxSupplyReached()
        );
        tokenId = ++LETSBaseStorage.LETSBaseSlot().nextTokenId;
        ERC721Lib.safeMint(to, tokenId);
    }

    /**
     * @notice Mint a token
     * @param to The address to mint the token to
     * @param tokenId The token ID to mint
     * @return tokenId The token ID
     */
    function mint(address to, uint256 tokenId) internal returns (uint256) {
        require(
            tokenId == 0 ||
                LETSBaseStorage.LETSBaseSlot().maxSupply >= tokenId,
            ILETSBaseErrors.MaxSupplyReached()
        );
        ERC721Lib.safeMint(to, tokenId);
        return tokenId;
    }

    /**
     * @notice Freeze a token
     * @param tokenId The token ID
     */
    function freezeToken(uint256 tokenId) internal {
        LETSBaseStorage.LETSBaseSlot().freezeToken[tokenId] = true;
        emit ILETSBaseEvents.TokenFrozen(tokenId);
    }

    /**
     * @notice Unfreeze a token
     * @param tokenId The token ID
     */
    function unfreezeToken(uint256 tokenId) internal {
        LETSBaseStorage.LETSBaseSlot().freezeToken[tokenId] = false;
        emit ILETSBaseEvents.TokenUnfrozen(tokenId);
    }

    /**
     * @notice Increase the balance of an account
     * @param account The account to increase the balance of
     * @param amount The amount to increase the balance by
     */
    function _increaseBalance(address account, uint128 amount) internal {
        ERC721Storage.ERC721Slot().balances[account] += amount;
    }

    // ============================================== //
    //             INTERNAL READ FUNCTIONS            //
    // ============================================== //

    /**
     * @notice Get the SC address
     * @return The SC address
     */
    function getSC() internal view returns (address) {
        return LETSBaseStorage.LETSBaseSlot().sc;
    }

    /**
     * @notice Get the isMetadataFixed flag
     * @return The isMetadataFixed flag
     */
    function getIsMetadataFixed() internal view returns (bool) {
        return LETSBaseStorage.LETSBaseSlot().isMetadataFixed;
    }

    /**
     * @notice Get the next token ID
     * @return The next token ID
     */
    function getNextTokenId() internal view returns (uint256) {
        return LETSBaseStorage.LETSBaseSlot().nextTokenId;
    }

    /**
     * @notice Get the max supply
     * @return The max supply
     */
    function getMaxSupply() internal view returns (uint256) {
        return LETSBaseStorage.LETSBaseSlot().maxSupply;
    }

    /**
     * @notice Get the base URI
     * @return The base URI
     */
    function getBaseURI() internal view returns (string memory) {
        return LETSBaseStorage.LETSBaseSlot().baseURI;
    }

    /**
     * @notice Get the extension
     * @return The extension
     */
    function getExtension() internal view returns (string memory) {
        return LETSBaseStorage.LETSBaseSlot().extension;
    }

    /**
     * @notice Get the freeze token flag
     * @param tokenId The token ID
     * @return The freeze token flag
     */
    function getFreezeToken(uint256 tokenId) internal view returns (bool) {
        return LETSBaseStorage.LETSBaseSlot().freezeToken[tokenId];
    }

    /**
     * @notice Get the updated token timestamp
     * @param tokenId The token ID
     * @return The updated token timestamp
     */
    function getUpdatedToken(uint256 tokenId) internal view returns (uint256) {
        return LETSBaseStorage.LETSBaseSlot().updatedToken[tokenId];
    }
}
