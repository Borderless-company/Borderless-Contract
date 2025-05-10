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
    //             External Write Functions           //
    // ============================================== //

    /**
     * @dev Initial mint the given addresses
     * @param tos The addresses to mint
     * @param tokenId The token id to mint
     */
    function initialMint(address[] calldata tos, uint256 tokenId) external;

    // ============================================== //
    //             External Read Functions            //
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
