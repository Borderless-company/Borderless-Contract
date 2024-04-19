// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title feature interface for TokenService contract
interface ITokenService {
    function callAdmin() external returns(bool);
}
