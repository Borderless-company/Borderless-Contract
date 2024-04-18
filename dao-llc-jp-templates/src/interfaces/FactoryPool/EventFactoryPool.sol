// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title Event interface
interface EventFactoryPool {
   event NewService(address indexed service_, uint256 indexed index_);
   event UpdateService(address indexed service_, uint256 indexed index_, bool online_);
}
