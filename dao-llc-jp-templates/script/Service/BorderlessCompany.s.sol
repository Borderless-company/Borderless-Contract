// SPDX-License-Identifier: MIT
pragma solidity =0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {RegisterBorderlessCompany} from "src/Register/RegisterBorderlessCompany.sol";
import {Whitelist} from "src/Whitelist/Whitelist.sol";
import {FactoryPool} from "src/FactoryPool/FactoryPool.sol";
// -- Initial Service Factory -- //
import {GovernanceServiceFactory} from "src/FactoryPool/FactoryServices/GovernanceServiceFactory.sol";
import {TreasuryServiceFactory} from "src/FactoryPool/FactoryServices/TreasuryServiceFactory.sol";
import {TokenServiceFactory} from "src/FactoryPool/FactoryServices/TokenServiceFactory.sol";

contract BorderlessCompanyScript is Script {
    FactoryPool fp;
    RegisterBorderlessCompany rbc;
    Whitelist wl;
    GovernanceServiceFactory gnsf;
    TreasuryServiceFactory trsf;
    TokenServiceFactory tksf;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        wl = new Whitelist();

        rbc = new RegisterBorderlessCompany(address(wl));

        fp = new FactoryPool(address(rbc));

        rbc.setFactoryPool(address(fp));

        // Governance
        gnsf = new GovernanceServiceFactory(address(rbc));
        // Treasury
        trsf = new TreasuryServiceFactory(address(rbc));
        // Token
        tksf = new TokenServiceFactory(address(rbc));

        // -- Set Service Address -- //
        fp.setService(address(gnsf), 1); // index = 1 GovernanceService
        fp.setService(address(trsf), 2); // index = 2 TreasuryService
        fp.setService(address(tksf), 3); // index = 3 TokenService

        // -- Activate Service Address -- //
        fp.updateService(address(gnsf), 1, true); // index = 1 GovernanceService
        fp.updateService(address(trsf), 2, true); // index = 2 TreasuryService
        fp.updateService(address(tksf), 3, true); // index = 3 TokenService

        vm.stopBroadcast();
    }
}
