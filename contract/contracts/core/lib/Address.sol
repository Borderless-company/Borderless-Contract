// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title Address
 * @notice Address is a library that provides utility functions for addresses.
 */
library Address {
    /// @notice check if the address is not zero
    function checkAddress(address account) internal pure returns (bool) {
        return account != address(0);
    }
}
