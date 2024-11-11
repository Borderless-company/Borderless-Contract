// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

/// @title feature interface for GovernanceService contract
interface IGovernanceService {
    function callAdmin() external returns (bool);
}
