// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {LETSBase} from "../../LETSBase.sol";
import {ILETS_JP_LLC_EXE} from "./interfaces/ILETS_JP_LLC_EXE.sol";
import {IErrors} from "../../../../utils/IErrors.sol";
import {Constants} from "../../../../lib/Constants.sol";

// OpenZeppelin
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

/// @title Legal Embedded Token Service
contract LETS_JP_LLC_EXE is Initializable, LETSBase, ILETS_JP_LLC_EXE {
    // ============================================== //
    //                    Storage                     //
    // ============================================== //

    bool private _initialMintExecuteMemberCompleted;

    // ============================================== //
    //                  Modifier                      //
    // ============================================== //

    modifier onlySCRAndNotInitialMintExecuteMemberCompleted() {
        require(
            !_initialMintExecuteMemberCompleted,
            IErrors.InitialMintExecuteMemberCompleted()
        );
        require(
            IAccessControl(_sc.getSCR()).hasRole(
                Constants.FOUNDER_ROLE,
                msg.sender
            ),
            IErrors.NotFounder(msg.sender)
        );
        _;
    }

    modifier restrictTransfer(uint256 tokenId) {
        if (_ownerOf(tokenId) != address(0)) {
            require(msg.sender == _governance, NotTransferable());
        }
        _;
    }

    // ============================================== //
    //                  Constructor                   //
    // ============================================== //

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ============================================== //
    //                  Initializer                   //
    // ============================================== //

    function initialize(
        address owner,
        address sc,
        bytes memory params
    ) external initializer {
        __LETSBase_initialize(owner, sc, params);
        uint256 tokenId = ++_nextTokenId;
        _safeMint(owner, tokenId);
    }

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    function initialMint(
        address[] calldata tos,
        uint256 tokenId
    ) external override onlySCRAndNotInitialMintExecuteMemberCompleted {
        for (uint256 i = 0; i < tos.length; i++) {
            _safeMint(tos[i], tokenId);
        }
        _initialMintExecuteMemberCompleted = true;
        emit InitialMint(address(this), tos);
    }

    // ============================================== //
    //             External Read Functions            //
    // ============================================== //

    function getInitialMintExecuteMemberCompleted()
        external
        view
        returns (bool initialMintExecuteMemberCompleted)
    {
        initialMintExecuteMemberCompleted = _initialMintExecuteMemberCompleted;
    }

    // ============================================== //
    //               ERC721 Overrides                 //
    // ============================================== //

    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override restrictTransfer(tokenId) returns (address) {
        return super._update(to, tokenId, auth);
    }
}
