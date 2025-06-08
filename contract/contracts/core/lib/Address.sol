// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title Address
 * @notice Address is a library that provides utility functions for addresses.
 */
library Address {
    // ============================================== //
    //                ERRORS                         //
    // ============================================== //

    error ZeroAddress(address account);

    // ============================================== //
    //                FUNCTIONS                      //
    // ============================================== //

    /// @notice check if the address is not zero
    function isZeroAddress(address account) internal pure returns (bool) {
        return account == address(0);
    }

    function checkZeroAddress(address account) internal pure {
        require(!isZeroAddress(account), ZeroAddress(account));
    }
}
