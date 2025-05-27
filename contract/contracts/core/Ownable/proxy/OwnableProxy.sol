// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IOwnableFunctions} from "../interfaces/IOwnableFunctions.sol";

contract OwnableProxy is IOwnableFunctions {
    // ============================================== //
    //             EXTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    function renounceOwnership() external override {}

    function transferOwnership(address newOwner) external override {}

    // ============================================== //
    //             EXTERNAL READ FUNCTIONS            //
    // ============================================== //

    function owner() external view override returns (address) {}
}
