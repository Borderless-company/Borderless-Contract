// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

/// @title Interface for LETS_JP_LLC_EXE contract
interface ILETS_JP_LLC_EXE {
    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    /**
     * @dev Set the mint reserve for the given address
     * @param to The address to set the mint reserve for
     */
    function setMintReserve(address to) external;
}
