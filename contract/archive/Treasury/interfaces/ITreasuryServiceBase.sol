// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @title feature interface for TreasuryService contract
interface ITreasuryServiceBase {
    function callAdmin() external returns (bool);
}
