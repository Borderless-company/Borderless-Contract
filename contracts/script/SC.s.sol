// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.27;

import {Script, console} from "forge-std/Script.sol";
import {SCR} from "../src/SCR/SCR.sol";
import {SCT} from "../src/SCT/SCT.sol";
import {SC_JP_DAOLLC} from "../src/SCT/extentions/SC_JP_DAOLLC.sol";
import {ServiceFactory} from "../src/Factory/ServiceFactory.sol";
import {LETS_JP_LLC_EXE} from "../src/Services/LETS/extentions/LETS_JP_LLC/LETS_JP_LLC_EXE.sol";
import {LETS_JP_LLC_NON_EXE} from "../src/Services/LETS/extentions/LETS_JP_LLC/LETS_JP_LLC_NON_EXE.sol";
import {Governance_JP_LLC} from "../src/Services/Governance/extentions/Governance_JP_LLC.sol";
import {IServiceFactory} from "../src/Factory/interfaces/IServiceFactory.sol";
import {Upgrades} from "openzeppelin-foundry-upgrades/Upgrades.sol";
import {console} from "forge-std/console.sol";

contract SCScript is Script {
    SCR public scr;
    ServiceFactory public serviceFactory;
    SC_JP_DAOLLC public sc_jp_daollc;
    LETS_JP_LLC_EXE public lets_jp_llc_exe;
    LETS_JP_LLC_NON_EXE public lets_jp_llc_non_exe;
    Governance_JP_LLC public governance_jp_llc;

    address public serviceFactoryContractAddress;
    address public scrContractAddress;
    address public sc_jp_daollcContractAddress;
    address public lets_jp_llc_exeContractAddress;
    address public lets_jp_llc_non_exeContractAddress;
    address public governance_jp_llcContractAddress;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        console.log("deployerPrivateKey", deployerPrivateKey);
        vm.startBroadcast(deployerPrivateKey);

        /**********************************/
        /*          ServiceFactory        */
        /**********************************/

        address serviceFactoryProxy = Upgrades.deployUUPSProxy(
            "ServiceFactory.sol:ServiceFactory",
            abi.encodeCall(ServiceFactory.initialize, ())
        );
        serviceFactory = ServiceFactory(serviceFactoryProxy);
        serviceFactoryContractAddress = address(serviceFactory);
        console.log(
            "serviceFactoryContractAddress",
            serviceFactoryContractAddress
        );

        /**********************************/
        /*              SCR               */
        /**********************************/

        address scrProxy = Upgrades.deployUUPSProxy(
            "SCR.sol:SCR",
            abi.encodeCall(SCR.initialize, (serviceFactoryContractAddress))
        );
        scr = SCR(scrProxy);
        scrContractAddress = address(scr);
        console.log("scrContractAddress", scrContractAddress);

        /**********************************/
        /*              SCT               */
        /**********************************/

        sc_jp_daollc = new SC_JP_DAOLLC();
        sc_jp_daollcContractAddress = address(sc_jp_daollc);

        console.log("sc_jp_daollcContractAddress", sc_jp_daollcContractAddress);

        /**********************************/
        /*             Services           */
        /**********************************/

        lets_jp_llc_exe = new LETS_JP_LLC_EXE();
        lets_jp_llc_exeContractAddress = address(lets_jp_llc_exe);

        console.log(
            "lets_jp_llc_exeContractAddress",
            lets_jp_llc_exeContractAddress
        );

        lets_jp_llc_non_exe = new LETS_JP_LLC_NON_EXE();
        lets_jp_llc_non_exeContractAddress = address(lets_jp_llc_non_exe);
        console.log(
            "lets_jp_llc_non_exeContractAddress",
            lets_jp_llc_non_exeContractAddress
        );

        governance_jp_llc = new Governance_JP_LLC();
        governance_jp_llcContractAddress = address(governance_jp_llc);
        console.log(
            "governance_jp_llcContractAddress",
            governance_jp_llcContractAddress
        );

        /**********************************/
        /*            Set Role            */
        /**********************************/
        // scr.grantRole(FOUNDER_ROLE, founder);


        /**********************************/
        /*          Run Functions         */
        /**********************************/

        serviceFactory.setSCR(scrContractAddress);
        scr.setSCContract(address(sc_jp_daollc), "SC_JP_DAOLLC");
        scr.addCompanyInfoFields("SC_JP_DAOLLC", "zip_code");
        scr.addCompanyInfoFields("SC_JP_DAOLLC", "prefecture");
        scr.addCompanyInfoFields("SC_JP_DAOLLC", "city");
        scr.addCompanyInfoFields("SC_JP_DAOLLC", "address");

        serviceFactory.setService(
            address(lets_jp_llc_exe),
            "LETS_JP_LLC_EXE",
            IServiceFactory.ServiceType.LETS_EXE
        );
        serviceFactory.setService(
            address(lets_jp_llc_non_exe),
            "LETS_JP_LLC_NON_EXE",
            IServiceFactory.ServiceType.LETS_NON_EXE
        );
        serviceFactory.setService(
            address(governance_jp_llc),
            "Governance_JP_LLC",
            IServiceFactory.ServiceType.GOVERNANCE
        );


        vm.stopBroadcast();
    }
}
