// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {LETSBase} from "../../LETSBase.sol";
import {LETS_JP_LLC_NON_EXEInitializeLib} from "../../../libs/extensions/LETS_JP_LLC/LETS_JP_LLC_NON_EXEInitializeLib.sol";

/**
 * @title Non Executable Legal Embedded Token Service
 */
contract LETS_JP_LLC_NON_EXE is LETSBase {
    // ============================================== //
    //                    INITIALIZE                  //
    // ============================================== //

    function initialize(
        address dictionary,
        address implementation,
        address sc,
        bytes memory params
    ) public virtual override returns (bytes4[] memory selectors) {
        selectors = super.initialize(
            dictionary,
            implementation,
            sc,
            params
        );
        LETS_JP_LLC_NON_EXEInitializeLib.initialize(
            dictionary,
            selectors,
            implementation
        );
    }
}
