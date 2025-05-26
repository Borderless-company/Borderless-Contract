// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title Borderless LETS Schema v0.1.0
 */
library Schema {
    struct LETSBaseLayout {
        address sc;
        bool isMetadataFixed;
        uint256 nextTokenId;
        uint256 maxSupply;
        string baseURI;
        string extension;

        /**
        * @dev freeze the token
        */
        mapping(uint256 => bool) freezeToken;

        /**
        * @dev timestamp of the mint or transfer of the token
        */
        mapping(uint256 => uint256) updatedToken;
    }

    struct LETSSaleBaseLayout {
        address scr;
        uint256 saleStart;
        uint256 saleEnd;
        uint256 fixedPrice;
        uint256 minPrice;
        uint256 maxPrice;
        bool isSaleActive;
    }
}
