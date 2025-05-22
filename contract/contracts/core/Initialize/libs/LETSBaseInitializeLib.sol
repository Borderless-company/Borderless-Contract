// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// lib
import {Dictionary} from "../../Dictionary/Dictionary.sol";

// storage
import {Schema as InitializeSchema} from "../storages/Schema.sol";
import {Storage as InitializeStorage} from "../storages/Storage.sol";

// interfaces
import {InitializeErrors} from "../interfaces/InitializeErrors.sol";

library LETSBaseInitializeLib {
    event LETSBaseInitialized(address indexed initializer);

    function initialize(address dictionary) internal {
        InitializeSchema.InitializeLayout storage $init = InitializeStorage
            .InitializeSlot();
        require(
            !$init.initialized,
            InitializeErrors.AlreadyInitialized()
        );
        bytes4[] memory selectors = new bytes4[](21);
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
        selectors[10] = bytes4(keccak256("transferFrom(address,address,uint256)"));
        selectors[11] = bytes4(keccak256("safeTransferFrom(address,address,uint256)"));
        selectors[12] = bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)"));
        selectors[13] = bytes4(keccak256("name()"));
        selectors[14] = bytes4(keccak256("symbol()"));
        selectors[15] = bytes4(keccak256("tokenByIndex(uint256)"));
        selectors[16] = bytes4(keccak256("tokenOfOwnerByIndex(address,uint256)"));
        selectors[17] = bytes4(keccak256("getTokensOfOwner(address)"));
        selectors[18] = bytes4(keccak256("freezeToken(uint256)"));
        selectors[19] = bytes4(keccak256("unfreezeToken(uint256)"));
        selectors[20] = bytes4(keccak256("getUpdatedToken(uint256)"));
        for (uint256 i = 0; i < selectors.length; i++) {
            Dictionary(dictionary).setImplementation(
                selectors[i],
                address(this)
            );
        }
        emit LETSBaseInitialized(msg.sender);
    }
}
