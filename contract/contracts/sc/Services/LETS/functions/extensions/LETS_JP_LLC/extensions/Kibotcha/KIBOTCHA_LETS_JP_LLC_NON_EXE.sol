// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {LETS_JP_LLC_NON_EXE} from "../../LETS_JP_LLC_NON_EXE.sol";

// storage
import {Storage as LETSBaseStorage} from "../../../../../storages/Storage.sol";

// lib
import {LETS_JP_LLC_NON_EXEInitializeLib} from "../../../../../libs/extensions/LETS_JP_LLC/LETS_JP_LLC_NON_EXEInitializeLib.sol";
import {ERC721Lib} from "../../../../../../../ERC721/libs/ERC721Lib.sol";
import {Constants} from "../../../../../../../../core/lib/Constants.sol";

// interface
import {IErrors} from "../../../../../../../../core/utils/IErrors.sol";

// OpenZeppelin
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

struct InitParams {
    string name;
    string symbol;
    string baseURI;
    string extension;
    bool isMetadataFixed;
    uint256 maxSupply;
}

/**
 * @title Legal Embedded Token Service
 */
contract KIBOTCHA_LETS_JP_LLC_NON_EXE is LETS_JP_LLC_NON_EXE {
    // ============================================== //
    //                INITIALIZE                  //
    // ============================================== //

    error InvalidTokenId(uint256 tokenId);

    // ============================================== //
    //                INITIALIZE                  //
    // ============================================== //

    function initialize(
        address dictionary,
        address implementation,
        address sc,
        bytes memory params
    ) public override returns (bytes4[] memory selectors) {
        (
            string memory name,
            string memory symbol,
            string memory baseURI,
            string memory extension,
            bool isMetadataFixed,
            uint256 maxSupply,
            uint256 baseTokenId
        ) = abi.decode(
                params,
                (string, string, string, string, bool, uint256, uint256)
            );
        bytes memory params_ = abi.encode(
            name,
            symbol,
            baseURI,
            extension,
            isMetadataFixed,
            maxSupply
        );

        selectors = super.initialize(dictionary, implementation, sc, params_);
        LETSBaseStorage.LETSBaseSlot().nextTokenId = baseTokenId;
    }

    // ============================================== //
    //             Eternal Write Functions            //
    // ============================================== //

    function reserveMint(address to, uint256 tokenId) external {
        require(
            IAccessControl(LETSBaseStorage.LETSBaseSlot().sc).hasRole(
                Constants.FOUNDER_ROLE,
                msg.sender
            ),
            IErrors.NotFounder(msg.sender)
        );
        require(tokenId <= 708, InvalidTokenId(tokenId));
        ERC721Lib.safeMint(to, tokenId);
    }
}
