// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @title feature interface for LETSService contract
interface ILETSBase {
    // ============================================== //
	//                     Events                     //
	// ============================================== //

	/**
	 * @dev token frozen event
	 * @param tokenId token id
	 */
	event TokenFrozen(uint256 tokenId);

	/**
	 * @dev token unfrozen event
	 * @param tokenId token id
	 */
	event TokenUnfrozen(uint256 tokenId);

    // ============================================== //
	//                     Errors                     //
	// ============================================== //

    /**
	 * @dev not lets sale error
	 * @param caller caller address
	 */
	error NotLetsSale(address caller);

	/**
	 * @dev not governance error
	 * @param caller caller address
	 */
	error NotGovernance(address caller);

	/**
	 * @dev not transferable error
	 */
	error NotTransferable();

    // ============================================== //
	//             External Write Functions           //
	// ============================================== //

    /**
     * @notice Mint a token to the given address
     * @param to The address to mint the token to
     * @param tokenId The token ID to mint
     */
    function mint(address to, uint256 tokenId) external;

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
     * @notice Get the SC address
     * @return The SC address
     */
    function getSC() external view returns (address);

    /**
     * @notice Get the LetsSale address
     * @return The LetsSale address
     */
    function getLetsSale() external view returns (address);

    /**
     * @notice Get the updated token timestamp
     * @param tokenId The token ID
     * @return The updated token timestamp
     */
    function getUpdatedToken(uint256 tokenId) external view returns (uint256);

    /**
     * @notice Get the tokens of the owner
     * @param owner The owner address
     * @return The tokens of the owner
     */
    function getTokensOfOwner(
        address owner
    ) external view returns (uint256[] memory);
}
