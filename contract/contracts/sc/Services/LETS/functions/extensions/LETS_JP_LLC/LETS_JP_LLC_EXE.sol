// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {LETSBase} from "../../LETSBase.sol";
import {ILETS_JP_LLC_EXE} from "./interfaces/ILETS_JP_LLC_EXE.sol";

// storage
import {Storage as LETSBaseStorage} from "../../../storages/Storage.sol";

// lib
import {LETSBaseLib} from "../../../libs/LETSBaseLib.sol";
import {Constants} from "../../../../../../core/lib/Constants.sol";
import {LETS_JP_LLC_EXEInitializeLib} from "../../../libs/extensions/LETS_JP_LLC/LETS_JP_LLC_EXEInitializeLib.sol";

// OpenZeppelin
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

/// @title Legal Embedded Token Service
contract LETS_JP_LLC_EXE is LETSBase, ILETS_JP_LLC_EXE {
    // ============================================== //
    //                    Storage                     //
    // ============================================== //

    bool private _initialMintExecuteMemberCompleted;

    // ============================================== //
    //                 Initialization                 //
    // ============================================== //

    function initialize(
        address dictionary,
        address implementation,
        address sc,
        bytes calldata params
    ) public override returns (bytes4[] memory selectors) {
        selectors = super.initialize(dictionary, implementation, sc, params);
        LETS_JP_LLC_EXEInitializeLib.initialize(dictionary, selectors, implementation);
    }

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    function initialMint(address[] calldata tos) external {
        require(
            IAccessControl(LETSBaseStorage.LETSBaseSlot().sc).hasRole(
                Constants.FOUNDER_ROLE,
                msg.sender
            ),
            NotFounder(msg.sender)
        );
        for (uint256 i = 0; i < tos.length; i++) {
            LETSBaseLib.mint(tos[i]);
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
}
