// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {IFactoryPool} from "src/interfaces/FactoryPool/IFactoryPool.sol";

contract FactoryPool is IFactoryPool {
    address private _owner;
    uint256 private _lastIndex;
    mapping(uint256 index_ => ServiceInfo info_) _services;
}
