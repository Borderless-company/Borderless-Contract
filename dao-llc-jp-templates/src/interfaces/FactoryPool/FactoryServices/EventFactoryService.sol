// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title common interface for factory service
interface EventFactoryService {
    event ActivateBorderlessService(address indexed admin_, address indexed service, uint256 indexed serviceID);
}
