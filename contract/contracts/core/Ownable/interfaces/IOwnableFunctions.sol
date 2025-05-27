// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IOwnableFunctions {
    // ============================================== //
    //             EXTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    /**
     * @notice Renounce ownership of the contract.
     */
    function renounceOwnership() external;

    /**
     * @notice Transfer ownership of the contract to a new account.
     */
    function transferOwnership(address newOwner) external;

    // ============================================== //
    //             EXTERNAL READ FUNCTIONS            //
    // ============================================== //

    /**
     * @notice Returns the address of the current owner.
     */
    function owner() external view returns (address);
}