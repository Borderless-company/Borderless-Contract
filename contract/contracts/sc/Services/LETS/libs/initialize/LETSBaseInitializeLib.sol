// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Dictionary} from "../../../../../core/Dictionary/functions/Dictionary.sol";

// storage
import {Storage as LETSBaseStorage} from "../../storages/Storage.sol";
import {Schema as LETSBaseSchema} from "../../storages/Schema.sol";
import {Storage as ERC721Storage} from "../../../../ERC721/storages/Storage.sol";
import {Schema as ERC721Schema} from "../../../../ERC721/storages/Schema.sol";
import {Storage as InitializeStorage} from "../../../../../core/Initialize/storages/Storage.sol";
import {Schema as InitializeSchema} from "../../../../../core/Initialize/storages/Schema.sol";

// interfaces
import {IErrors} from "../../../../../core/utils/IErrors.sol";
import {InitializeErrors} from "../../../../../core/Initialize/interfaces/InitializeErrors.sol";

/**
 * @title LETSBaseInitializeLib
 * @notice Library for initializing the LETSBase contract
 */
library LETSBaseInitializeLib {
    function initialize(
        address sc,
        bytes calldata params
    ) internal returns (bytes4[] memory selectors) {
        (
            string memory name,
            string memory symbol,
            string memory baseURI,
            string memory extension,
            bool isMetadataFixed,
            uint256 maxSupply
        ) = abi.decode(params, (string, string, string, string, bool, uint256));
        require(
            bytes(name).length > 0 &&
                bytes(symbol).length > 0 &&
                bytes(baseURI).length > 0 &&
                bytes(extension).length > 0,
            IErrors.InvalidParam(bytes32(params))
        );

        ERC721Schema.ERC721Layout storage $erc721 = ERC721Storage.ERC721Slot();
        LETSBaseSchema.LETSBaseLayout storage $base = LETSBaseStorage
            .LETSBaseSlot();

        $erc721.name = name;
        $erc721.symbol = symbol;

        $base.sc = sc;
        $base.baseURI = baseURI;
        $base.extension = extension;
        $base.isMetadataFixed = isMetadataFixed;
        $base.maxSupply = maxSupply;

        selectors = _registerSelectors();
    }

    event LETSBaseInitialized(address indexed initializer);

    function _registerSelectors() internal returns (bytes4[] memory selectors) {
        InitializeSchema.InitializeLayout storage $init = InitializeStorage
            .InitializeSlot();
        require(!$init.initialized, InitializeErrors.AlreadyInitialized());
        selectors = new bytes4[](22);
        selectors[0] = bytes4(keccak256("getUpdatedToken(uint256)"));
        selectors[1] = bytes4(keccak256("tokenURI(uint256)"));
        selectors[2] = bytes4(keccak256("totalSupply()"));
        selectors[3] = bytes4(keccak256("supportsInterface(bytes4)"));
        selectors[4] = bytes4(keccak256("balanceOf(address)"));
        selectors[5] = bytes4(keccak256("ownerOf(uint256)"));
        selectors[6] = bytes4(keccak256("approve(address,uint256)"));
        selectors[7] = bytes4(keccak256("getApproved(uint256)"));
        selectors[8] = bytes4(keccak256("setApprovalForAll(address,bool)"));
        selectors[9] = bytes4(keccak256("isApprovedForAll(address,address)"));
        selectors[10] = bytes4(
            keccak256("transferFrom(address,address,uint256)")
        );
        selectors[11] = bytes4(
            keccak256("safeTransferFrom(address,address,uint256)")
        );
        selectors[12] = bytes4(
            keccak256("safeTransferFrom(address,address,uint256,bytes)")
        );
        selectors[13] = bytes4(keccak256("name()"));
        selectors[14] = bytes4(keccak256("symbol()"));
        selectors[15] = bytes4(keccak256("tokenByIndex(uint256)"));
        selectors[16] = bytes4(
            keccak256("tokenOfOwnerByIndex(address,uint256)")
        );
        selectors[17] = bytes4(keccak256("getTokensOfOwner(address)"));
        selectors[18] = bytes4(keccak256("mint(address)"));
        selectors[19] = bytes4(keccak256("freezeToken(uint256)"));
        selectors[20] = bytes4(keccak256("unfreezeToken(uint256)"));
        selectors[21] = bytes4(keccak256("getUpdatedToken(uint256)"));
        emit LETSBaseInitialized(msg.sender);
    }
}
