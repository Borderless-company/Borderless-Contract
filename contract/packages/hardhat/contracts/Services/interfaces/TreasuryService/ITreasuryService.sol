// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

/// @title feature interface for TreasuryService contract
interface ITreasuryService {
    function callAdmin() external returns (bool);
}
