// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title Error interface
interface ErrorFactoryPool {
   error InvalidParam(address service_, uint256 index_, bool online_);
}
