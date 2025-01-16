// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Test} from "forge-std/Test.sol";
import {SCR} from "../contracts/SCR/SCR.sol";
import {SC_JP_DAOLLC} from "../contracts/SCT/extentions/SC_JP_DAOLLC.sol";
import {ServiceFactory} from "../contracts/Factory/ServiceFactory.sol";
import {LETS_JP_LLC_EXE} from "../contracts/Services/LETS/extentions/LETS_JP_LLC/LETS_JP_LLC_EXE.sol";
import {LETS_JP_LLC_NON_EXE} from "../contracts/Services/LETS/extentions/LETS_JP_LLC/LETS_JP_LLC_NON_EXE.sol";
import {Governance_JP_LLC} from "../contracts/Services/Governance/extentions/Governance_JP_LLC.sol";

// interfaces
import {IServiceFactory} from "../contracts/Factory/interfaces/IServiceFactory.sol";

import {ECDSA} from "solady/utils/ECDSA.sol";
// Upgrades
import {Upgrades} from "@openzeppelin/foundry-upgrades/Upgrades.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "forge-std/console.sol";

contract Common is Test {
    using ECDSA for bytes32;

    // proxy
    address public scrProxy;
    address public serviceFactoryProxy;

    // contract
    SCR public scr;
    ServiceFactory public serviceFactory;
    SC_JP_DAOLLC public sc_jp_daollc;
    LETS_JP_LLC_EXE public lets_jp_llc_exe;
    LETS_JP_LLC_NON_EXE public lets_jp_llc_non_exe;
    Governance_JP_LLC public governance_jp_llc;

    // contract address
    address public scrContractAddress;
    address public serviceFactoryContractAddress;
    address public sc_jp_daollcContractAddress;
    address public lets_jp_llc_exeContractAddress;
    address public lets_jp_llc_non_exeContractAddress;
    address public governance_jp_llcContractAddress;

    // user
    address public admin;
    address public founder;
    address public executionMember;
    address public executionMember2;
    address public member1;
    address public member2;

    // solhint-disable-next-line var-name-mixedcase
    bytes32 public DEFAULT_ADMIN_ROLE;
    // solhint-disable-next-line var-name-mixedcase
    bytes32 public FOUNDER_ROLE;

    // hash
    bytes32 public hash;
    bytes public signature;
    bytes32 public adminHash;
    bytes public adminSignature;
    bytes32 public operatorHash;
    bytes public operatorSignature;

    function setUp() public virtual {
        /**********************************/
        /*              User              */
        /**********************************/
        (admin, ) = makeAddrAndKey("admin");
        (founder, ) = makeAddrAndKey("founder");
        (executionMember, ) = makeAddrAndKey("executionMember");
        (executionMember2, ) = makeAddrAndKey("executionMember2");
        (member1, ) = makeAddrAndKey("member1");
        (member2, ) = makeAddrAndKey("member2");

        vm.startPrank(admin);

        /**********************************/
        /*          ServiceFactory        */
        /**********************************/

        serviceFactoryProxy = Upgrades.deployUUPSProxy(
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

        scrProxy = Upgrades.deployUUPSProxy(
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
        DEFAULT_ADMIN_ROLE = scr.DEFAULT_ADMIN_ROLE();
        FOUNDER_ROLE = scr.FOUNDER_ROLE();
        scr.grantRole(FOUNDER_ROLE, founder);

        vm.stopPrank();

        /**********************************/
        /*          Run Functions         */
        /**********************************/

        vm.startPrank(admin);
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

        vm.stopPrank();

        /**********************************/
        /*              Label             */
        /**********************************/
        vm.label(admin, "Admin");
        vm.label(executionMember, "ExecutionMember");
        vm.label(executionMember2, "ExecutionMember2");
        vm.label(member1, "Member1");
        vm.label(member2, "Member2");
        vm.label(scrContractAddress, "SCR");
        vm.label(sc_jp_daollcContractAddress, "SC_JP_DAOLLC");
        vm.label(lets_jp_llc_exeContractAddress, "LETS_JP_LLC_EXE");
        vm.label(lets_jp_llc_non_exeContractAddress, "LETS_JP_LLC_NON_EXE");
        vm.label(governance_jp_llcContractAddress, "Governance_JP_LLC");
    }
}
