// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @title Error interface for LETS_JP_LLC_NON_EXE contract
interface ErrorLETS_JP_LLC_NON_EXE {
    /**
     * @dev Not LETS non-exe sale Error
     * @param caller function caller
     */
    error NotLetsNonExeSale(address caller);
}
