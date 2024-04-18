// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {RegisterBorderlessCompany} from "src/Register/RegisterBorderlessCompany.sol";
import {Whitelist} from "src/Whitelist/Whitelist.sol";
import {FactoryPool} from "src/FactoryPool/FactoryPool.sol";

contract BorderlessCompanyScript is Script {
    FactoryPool fp;
    RegisterBorderlessCompany rbc;
    Whitelist wl;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        wl = new Whitelist();

        rbc = new RegisterBorderlessCompany(address(wl));

        fp = new FactoryPool(address(rbc));

        rbc.setFactoryPool(address(fp));

        vm.stopBroadcast();
    }
}
