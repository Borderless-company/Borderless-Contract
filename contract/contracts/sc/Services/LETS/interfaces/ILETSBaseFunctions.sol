// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ILETSBaseFunctions {
    // ============================================== //
    //             EXTERNAL WRITE FUNCTIONS           //
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
     * @notice Get the SC address
     * @return The SC address
     */
    function getSC() external view returns (address);

    /**
     * @notice Get the isMetadataFixed flag
     * @return The isMetadataFixed flag
     */
    function getIsMetadataFixed() external view returns (bool);

    /**
     * @notice Get the next token ID
     * @return The next token ID
     */
    function getNextTokenId() external view returns (uint256);

    /**
     * @notice Get the max supply
     * @return The max supply
     */
    function getMaxSupply() external view returns (uint256);

    /**
     * @notice Get the base URI
     * @return The base URI
     */
    function getBaseURI() external view returns (string memory);

    /**
     * @notice Get the extension
     * @return The extension
     */
    function getExtension() external view returns (string memory);

    /**
     * @notice Get the freeze token flag
     * @param tokenId The token ID
     * @return The freeze token flag
     */
    function getFreezeToken(uint256 tokenId) external view returns (bool);

    /**
     * @notice Get the updated token timestamp
     * @param tokenId The token ID
     * @return The updated token timestamp
     */
    function getUpdatedToken(uint256 tokenId) external view returns (uint256);
}
