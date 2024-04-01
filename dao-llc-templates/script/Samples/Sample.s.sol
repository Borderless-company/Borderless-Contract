// SPDX-License-Identifier: Apache-2.0
pragma solidity =0.8.23;

import {Script, console} from "forge-std/Script.sol";

contract SampleScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();
    }
}
