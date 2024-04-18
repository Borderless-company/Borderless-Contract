// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title common interface for factory service
interface IFactoryService {
    function activate(address admin_, address company_, uint256 serviceID_) external returns (address service_);
}
