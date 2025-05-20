// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";

/**
    @title ERC7546: Beacon Dictionary Contract
 */
contract BeaconDictionary is UpgradeableBeacon {
    constructor(address implementation_, address initialOwner) UpgradeableBeacon(implementation_, initialOwner) {}

    function getImplementation(bytes4) external view returns(address) {
        return implementation();
    }

}