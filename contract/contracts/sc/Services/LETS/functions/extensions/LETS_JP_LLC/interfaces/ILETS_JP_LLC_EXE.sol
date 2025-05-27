// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @title Interface for LETS_JP_LLC_EXE contract
interface ILETS_JP_LLC_EXE {
    // ============================================== //
    //                   Events                       //
    // ============================================== //

    event InitialMint(address indexed scr, address[] tos);

    // ============================================== //
    //                   Errors                       //
    // ============================================== //

    error NotFounder(address sender);

    // ============================================== //
    //             EXTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    /**
     * @dev Initial mint the given addresses
     * @param tos The addresses to mint
     */
    function initialMint(
        address[] calldata tos
    ) external;

    // ============================================== //
    //             EXTERNAL READ FUNCTIONS            //
    // ============================================== //

    /**
     * @dev Get the initial mint execute member completed
     * @return initialMintExecuteMemberCompleted The initial mint execute member completed
     */
    function getInitialMintExecuteMemberCompleted()
        external
        view
        returns (bool initialMintExecuteMemberCompleted);
}
