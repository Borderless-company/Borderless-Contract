// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import {Script, console} from "forge-std/Script.sol";

/// @dev deploy script contract for testing
contract Sample {
    address private _owner;

    constructor() {
        _owner = msg.sender;
    }

    function callOwner() public view onlyOwner returns(bool success_) {
        success_ = true;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Sample: Only-Owner");
        _;
    }
}

contract SampleScript is Script {
    Sample sp;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        sp = new Sample();
        
        vm.stopBroadcast();
    }
}
