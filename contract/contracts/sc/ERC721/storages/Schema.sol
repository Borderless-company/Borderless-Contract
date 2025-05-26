// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ServiceType} from "../../../core/utils/ITypes.sol";

/**
 * @title Borderless SCT Schema v0.1.0
 */
library Schema {
    struct ERC721Layout {
        // Token name
        string name;

        // Token symbol
        string symbol;

        // Token owner
        mapping(uint256 tokenId => address) owners;

        // Token balance
        mapping(address owner => uint256 balance) balances;

        // Token approval
        mapping(uint256 tokenId => address operator) tokenApprovals;

        // Operator approval
        mapping(address owner => mapping(address operator => bool isApproved)) operatorApprovals;
    }

    struct ERC721URIStorageLayout {
        // Token URI
        mapping(uint256 tokenId => string uri) tokenURIs;
    }

    struct ERC721EnumerableLayout {
        mapping(address owner => mapping(uint256 index => uint256 tokenId)) ownedTokens;
        mapping(uint256 tokenId => uint256 index) ownedTokensIndex;

        uint256[] allTokens;
        mapping(uint256 tokenId => uint256 index) allTokensIndex;
    }
}
