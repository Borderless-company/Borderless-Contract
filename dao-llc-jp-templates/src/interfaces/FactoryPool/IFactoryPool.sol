// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

interface IFactoryPool {
    struct ServiceInfo{
        address service;
        bool online;
    }

    // function setService(address service_) external;
    // function getService(uint256 index_) external returns(address service_, bool online_);
    // function updateService(address service_, uint256 index_) external;
    // function updateService(address service_, uint256 index_, bool online_) external;
}
