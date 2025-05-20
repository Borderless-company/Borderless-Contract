// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ILETSBaseFunctions {
    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    /**
     * @notice Mint a token to the given address
     * @param to The address to mint the token to
     * @return tokenId The token ID to mint
     */
    function mint(address to) external returns (uint256 tokenId);

    /**
     * @notice Freeze the token with the given ID
     * @param tokenId The token ID to freeze
     */
    function freezeToken(uint256 tokenId) external;

    /**
     * @notice Unfreeze the token with the given ID
     * @param tokenId The token ID to unfreeze
     */
    function unfreezeToken(uint256 tokenId) external;

    // ============================================== //
    //             Eternal Read Functions             //
    // ============================================== //

    /**
     * @notice Get the updated token timestamp
     * @param tokenId The token ID
     * @return The updated token timestamp
     */
    function getUpdatedToken(uint256 tokenId) external view returns (uint256);
}
