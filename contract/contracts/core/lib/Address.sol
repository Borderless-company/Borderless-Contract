// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @notice address utility functions
 */
library Address {
    /// @notice check if the address is not zero
    function checkAddress(address account) internal pure returns (bool) {
        return account != address(0);
    }
}
