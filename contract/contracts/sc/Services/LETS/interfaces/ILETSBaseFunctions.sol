// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ILETSBaseFunctions {
    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    /**
     * @notice Initialize the contract
     * @param dictionary The dictionary address
     * @param implementation The implementation address
     * @param sc The sc address
     * @param params The parameters
     */
    function initialize(
        address dictionary,
        address implementation,
        address sc,
        bytes calldata params
    ) external returns (bytes4[] memory selectors);

    /**
     * @notice Mint a new token
     * @param to The address to mint the token to
     */
    function mint(address to) external;

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
