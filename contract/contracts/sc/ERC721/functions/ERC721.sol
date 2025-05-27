// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage as ERC721Storage} from "../storages/Storage.sol";
import {Storage as LETSBaseStorage} from "../../Services/LETS/storages/Storage.sol";

// lib
import {ERC721Lib} from "../libs/ERC721Lib.sol";

// interfaces
import {IERC721} from "../interfaces/IERC721.sol";

import {Ownable} from "../../../core/Ownable/functions/Ownable.sol";
import {LibString} from "solady/src/utils/LibString.sol";

// OpenZeppelin
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

contract ERC721 is IERC721, Ownable {
    using LibString for uint256;

    // ============================================== //
    //                 ERC165 Functions               //
    // ============================================== //
    function supportsInterface(
        bytes4 interfaceId
    ) public pure override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            interfaceId == type(IERC721Enumerable).interfaceId ||
            interfaceId == bytes4(0x49064906); // ERC4906
    }

    // ============================================== //
    //                 ERC721 Functions               //
    // ============================================== //

    function balanceOf(address owner) public view override returns (uint256) {
        return ERC721Lib.balanceOf(owner);
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        return ERC721Lib.requireOwned(tokenId);
    }

    function approve(address to, uint256 tokenId) public override {
        ERC721Lib.approve(to, tokenId, msg.sender);
    }

    function getApproved(
        uint256 tokenId
    ) public view override returns (address) {
        ERC721Lib.requireOwned(tokenId);
        return ERC721Lib.getApproved(tokenId);
    }

    function setApprovalForAll(
        address operator,
        bool approved
    ) public override {
        ERC721Lib.setApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(
        address owner,
        address operator
    ) public view override returns (bool) {
        return ERC721Lib.isApprovedForAll(owner, operator);
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        if (to == address(0)) revert ERC721InvalidReceiver(address(0));
        address previousOwner = _update(to, tokenId, msg.sender);
        if (previousOwner != from)
            revert ERC721IncorrectOwner(from, tokenId, previousOwner);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public override {
        transferFrom(from, to, tokenId);
        ERC721Lib.checkOnERC721Received(msg.sender, from, to, tokenId, data);
    }

    // ============================================== //
    //             ERC721 Metadata Functions          //
    // ============================================== //
    function name() public view override returns (string memory) {
        return ERC721Storage.ERC721Slot().name;
    }

    function symbol() public view override returns (string memory) {
        return ERC721Storage.ERC721Slot().symbol;
    }

    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        return ERC721Lib.tokenURI(tokenId);
    }

    // ============================================== //
    //            ERC721 Enumerable Functions         //
    // ============================================== //

    function totalSupply() public view override returns (uint256) {
        return ERC721Lib.totalSupply();
    }

    function tokenByIndex(
        uint256 index
    ) public view override returns (uint256) {
        return ERC721Lib.tokenByIndex(index);
    }

    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) public view virtual override returns (uint256) {
        return ERC721Lib.tokenOfOwnerByIndex(owner, index);
    }

    function getTokensOfOwner(
        address owner
    ) public view virtual override returns (uint256[] memory) {
        return ERC721Lib.getTokensOfOwner(owner);
    }

    // ============================================== //
    //                 Mint/Burn/Update               //
    // ============================================== //

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal returns (address) {
        if (to != address(0)) {
            LETSBaseStorage.LETSBaseSlot().updatedToken[tokenId] = block
                .timestamp;
        }
        return ERC721Lib.update(to, tokenId, auth);
    }

    function _mint(address to, uint256 tokenId) internal {
        ERC721Lib.mint(to, tokenId);
    }

    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        string memory _uri = string.concat(
            tokenId.toString(),
            LETSBaseStorage.LETSBaseSlot().extension
        );
        ERC721Lib.setTokenURI(tokenId, _uri);
        ERC721Lib.safeMint(to, tokenId, data);
    }

    function _burn(uint256 tokenId) internal {
        ERC721Lib.burn(tokenId);
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        ERC721Lib.transfer(from, to, tokenId);
    }

    function _safeTransfer(address from, address to, uint256 tokenId) internal {
        ERC721Lib.safeTransfer(from, to, tokenId);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        ERC721Lib.safeTransfer(from, to, tokenId, data);
    }

    // ============================================== //
    //                 URI Storage                    //
    // ============================================== //

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        ERC721Lib.setTokenURI(tokenId, _tokenURI);
    }
}
