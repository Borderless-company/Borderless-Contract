// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {RegisterBorderlessCompany} from "src/Register/RegisterBorderlessCompany.sol";
import {Whitelist} from "src/Whitelist/Whitelist.sol";

contract BorderlessCompanyScript is Script {
    RegisterBorderlessCompany rbc;
    Whitelist wl;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        wl = new Whitelist();

        rbc = new RegisterBorderlessCompany(address(wl));

        vm.stopBroadcast();
    }
}
