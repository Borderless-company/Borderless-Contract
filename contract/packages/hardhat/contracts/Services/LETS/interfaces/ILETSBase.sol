// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

/// @title feature interface for LETSService contract
interface ILETSBase {
    // ============================================== //
	//             External Write Functions           //
	// ============================================== //

    /**
     * @dev Mint a token to the given address
     * @param to The address to mint the token to
     * @param tokenId The token ID to mint
     */
    function mint(address to, uint256 tokenId) external;

    /**
     * @dev Freeze the token with the given ID
     * @param tokenId The token ID to freeze
     */
    function freezeToken(uint256 tokenId) external;

    /**
     * @dev Unfreeze the token with the given ID
     * @param tokenId The token ID to unfreeze
     */
    function unfreezeToken(uint256 tokenId) external;

    // ============================================== //
	//             External Read Functions            //
	// ============================================== //

    /**
     * @dev Get the total supply of the tokens
     * @return The total supply of the tokens
     */
    function totalSupply() external view returns (uint256);
}
