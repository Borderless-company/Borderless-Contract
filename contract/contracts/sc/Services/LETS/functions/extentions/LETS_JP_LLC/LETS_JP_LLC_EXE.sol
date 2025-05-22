// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {LETSBase} from "../../LETSBase.sol";
import {ILETS_JP_LLC_EXE} from "./interfaces/ILETS_JP_LLC_EXE.sol";

// lib
import {LETSSaleBaseInitializeLib} from "./initialize/libs/LETS_JP_LLC_EXEInitializeLib.sol";
import {LETSBaseLib} from "../../../libs/LETSBaseLib.sol";
import {BorderlessAccessControlLib} from "../../../../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";
import {Constants} from "../../../../../../core/lib/Constants.sol";

// OpenZeppelin
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

/// @title Legal Embedded Token Service
contract LETS_JP_LLC_EXE is LETSBase, ILETS_JP_LLC_EXE {
    // ============================================== //
    //                    Storage                     //
    // ============================================== //

    bool private _initialMintExecuteMemberCompleted;

    function initialize(address dictionary) public override {
        super.initialize(dictionary);
        LETSSaleBaseInitializeLib.initialize(dictionary);
    }

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    function initialMint(
        address[] calldata tos
    ) external {
        require(
            BorderlessAccessControlLib.hasRole(
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
