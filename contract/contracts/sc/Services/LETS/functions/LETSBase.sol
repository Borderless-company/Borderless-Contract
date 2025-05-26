// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ERC721} from "../../../ERC721/functions/ERC721.sol";

// storage
import {Storage as LETSBaseStorage} from "../storages/Storage.sol";

// lib
import {LETSBaseLib} from "../libs/LETSBaseLib.sol";
import {LETSBaseInitializeLib} from "../libs/initialize/LETSBaseInitializeLib.sol";

// interfaces
import {ILETSBase} from "../interfaces/ILETSBase.sol";
import {ISCT} from "../../../SCT/interfaces/ISCT.sol";
import {Constants} from "../../../../core/lib/Constants.sol";

// OpenZeppelin
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {console} from "hardhat/console.sol";

/**
 * @title Legal Embedded Token Service
 * @notice This contract is used to create a legal embedded token service.
 */
contract LETSBase is ERC721, ILETSBase {
    // ============================================== //
    //                Initialization                  //
    // ============================================== //

    function initialize(
        address,
        address,
        address sc,
        bytes calldata params
    ) public virtual override returns (bytes4[] memory selectors) {
        selectors = LETSBaseInitializeLib.initialize(sc, params);
        console.log("LETSBase initialized");
        console.log("sc", LETSBaseStorage.LETSBaseSlot().sc);
        console.log("baseURI", LETSBaseStorage.LETSBaseSlot().baseURI);
        console.log("extension", LETSBaseStorage.LETSBaseSlot().extension);
        console.log("isMetadataFixed", LETSBaseStorage.LETSBaseSlot().isMetadataFixed);
        console.log("maxSupply", LETSBaseStorage.LETSBaseSlot().maxSupply);
        console.log("nextTokenId", LETSBaseStorage.LETSBaseSlot().nextTokenId);
    }

    // ============================================== //
    //                MODIFIERS                       //
    // ============================================== //

    modifier onlyUnderMaxSupply() {
        require(
            LETSBaseStorage.LETSBaseSlot().maxSupply > super.totalSupply(),
            MaxSupplyReached()
        );
        _;
    }

    // ============================================== //
    //             Eternal Write Functions            //
    // ============================================== //

    function mint(address to) external override {
        require(
            IAccessControl(ISCT(LETSBaseStorage.LETSBaseSlot().sc).getSCR())
                .hasRole(Constants.MINTER_ROLE, msg.sender),
            IAccessControl.AccessControlUnauthorizedAccount(
                msg.sender,
                Constants.MINTER_ROLE
            )
        );
        LETSBaseLib.mint(to);
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

    // ============================================== //
    //            OVERRIDE ERC721 Functions           //
    // ============================================== //

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        return
            (LETSBaseStorage.LETSBaseSlot().isMetadataFixed)
                ? string.concat(
                    LETSBaseStorage.LETSBaseSlot().baseURI,
                    LETSBaseStorage.LETSBaseSlot().extension
                )
                : super.tokenURI(tokenId);
    }
}
