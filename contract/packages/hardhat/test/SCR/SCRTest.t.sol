// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {Common} from "../Common.sol";
import {SCR} from "../../contracts/SCR/SCR.sol";
import {SCT} from "../../contracts/SCT/SCT.sol";
import {ErrorSCR} from "../../contracts/SCR/interfaces/ErrorSCR.sol";
import {IServiceFactory} from "../../contracts/Factory/interfaces/IServiceFactory.sol";
import {LETSBase} from "../../contracts/Services/LETS/LETSBase.sol";
import {console} from "forge-std/console.sol";
import {IVote} from "../../contracts/Vote/interfaces/IVote.sol";
contract SCRTest is Common {
    bytes public scid = "TEST_DAO";
    string public legalEntityCode = "SC_JP_DAOLLC";
    string public companyName = "Test DAO Company";
    string public establishmentDate = "2024-01-01";
    string public jurisdiction = "JP";
    string public entityType = "LLC";
    bytes public scExtraParams = "";
    string[] public otherInfo;
    address[] public executionMemberAccounts;
    address[] public scsAddresses;

    function setUp() public override {
        super.setUp();
        otherInfo = [
            "100-0001",
            "Tokyo",
            "Shinjuku-ku",
            "Shinjuku 1-1-1"
        ];
        scsAddresses = [
            governance_jp_llcContractAddress,
            lets_jp_llc_exeContractAddress,
            lets_jp_llc_non_exeContractAddress
        ];
        executionMemberAccounts = [
            executionMember,
            executionMember2
        ];
    }

    function encodeParams(
        string memory _name,
        string memory _symbol,
        string memory _baseURI,
        string memory _extension,
        address _governance
    ) internal pure returns (bytes memory) {
        return
            abi.encode(
                _name,
                _symbol,
                _baseURI,
                _extension,
                _governance
            );
    }

    function testCreateSmartCompany_Success() public {
        bytes[] memory scsExtraParams = new bytes[](3);
        scsExtraParams[0] = "";
        scsExtraParams[1] = encodeParams(
            "LETS_JP_LLC_EXE",
            "LETS_JP_LLC_EXE",
            "https://example.com/metadata/",
            ".json",
            governance_jp_llcContractAddress
        );
        scsExtraParams[2] = encodeParams(
            "LETS_JP_LLC_NON_EXE",
            "LETS_JP_LLC_NON_EXE",
            "https://example.com/metadata/",
            ".json",
            governance_jp_llcContractAddress
        );
        vm.prank(founder);
        console.log("pre_scsAddresses[0]", scsAddresses[0]);
        console.log("pre_scsAddresses[1]", scsAddresses[1]);
        console.log("pre_scsAddresses[2]", scsAddresses[2]);
        (bool started, address companyAddress, address[] memory services) = scr.createSmartCompany(
            scid,
            sc_jp_daollcContractAddress,
            legalEntityCode,
            companyName,
            establishmentDate,
            jurisdiction,
            entityType,
            scExtraParams,
            otherInfo,
            scsAddresses,
            scsExtraParams
        );

        assertTrue(started, "Smart company creation should succeed");
        assertTrue(
            companyAddress != address(0),
            "Company address should be valid"
        );

        console.log("companyAddress", companyAddress);
        for (uint256 i = 0; i < services.length; i++) {
            console.log("services[i]", services[i]);
        }

        assertTrue(SCT(companyAddress).hasRole(SCT(companyAddress).DEFAULT_ADMIN_ROLE(), founder), "Founder should have DEFAULT_ADMIN_ROLE");

        address exeService = serviceFactory.getFounderServices(founder, IServiceFactory.ServiceType.LETS_EXE);

        assertEq(LETSBase(exeService).balanceOf(executionMember), 0, "EXE service should have 0 token");

        vm.startPrank(founder);
        LETSBase(exeService).mint(executionMember);
        vm.stopPrank();

        assertEq(LETSBase(exeService).balanceOf(executionMember), 1, "EXE service should have 1 token");

        // create proposal
        address voteProxy = scr.getVoteContract(founder);
        vm.prank(founder);
        IVote(voteProxy).createProposal(
            executionMember,
            "1",
            10,
            10,
            block.timestamp,
            block.timestamp + 100
        );

        // vote
        vm.prank(executionMember);
        IVote(voteProxy).vote("1", IVote.VoteType.Agree);
    }

    // function testCreateSmartCompany_Fail_AlreadyEstablished() public {
    //     bytes memory scid = "testSCID";
    //     address scImplementation = address(0x123);
    //     string memory legalEntityCode = "LEC123";
    //     string memory companyName = "Test Company";
    //     string memory dateOfIncorporation = "2023-01-01";
    //     string memory jurisdiction = "TestJurisdiction";
    //     string memory entityType = "LLC";
    //     bytes memory scExtraParams = "{}";
    //     string[] memory otherInfo = new string[](1);
    //     otherInfo[0] = "ExtraInfo1";
    //     address[] memory executionMemberAccounts = new address[](1);
    //     executionMemberAccounts[0] = admin;
    //     address[] memory scsAddresses = new address[](1);
    //     scsAddresses[0] = address(0x1234);
    //     bytes[] memory scsExtraParams = new bytes[](1);
    //     scsExtraParams[0] = "{}";

    //     vm.prank(admin);
    //     scr.addCompanyInfoFields(legalEntityCode, "Field1");

    //     vm.prank(admin);
    //     scr.createSmartCompany(
    //         scid,
    //         scImplementation,
    //         legalEntityCode,
    //         companyName,
    //         dateOfIncorporation,
    //         jurisdiction,
    //         entityType,
    //         scExtraParams,
    //         otherInfo,
    //         executionMemberAccounts,
    //         scsAddresses,
    //         scsExtraParams
    //     );

    //     vm.expectRevert(abi.encodeWithSelector(ErrorSCR.AlreadyEstablish.selector, admin));
    //     scr.createSmartCompany(
    //         scid,
    //         scImplementation,
    //         legalEntityCode,
    //         companyName,
    //         dateOfIncorporation,
    //         jurisdiction,
    //         entityType,
    //         scExtraParams,
    //         otherInfo,
    //         executionMemberAccounts,
    //         scsAddresses,
    //         scsExtraParams
    //     );
    // }

    // function testCreateSmartCompany_Fail_InvalidCompanyInfo() public {
    //     bytes memory scid = "";
    //     address scImplementation = address(0x123);
    //     string memory legalEntityCode = "LEC123";
    //     string memory companyName = "Test Company";
    //     string memory dateOfIncorporation = "2023-01-01";
    //     string memory jurisdiction = "";
    //     string memory entityType = "LLC";
    //     bytes memory scExtraParams = "{}";
    //     string[] memory otherInfo = new string[](1);
    //     otherInfo[0] = "ExtraInfo1";
    //     address[] memory executionMemberAccounts = new address[](1);
    //     executionMemberAccounts[0] = admin;
    //     address[] memory scsAddresses = new address[](1);
    //     scsAddresses[0] = address(0x1234);
    //     bytes[] memory scsExtraParams = new bytes[](1);
    //     scsExtraParams[0] = "{}";

    //     vm.prank(admin);
    //     scr.addCompanyInfoFields(legalEntityCode, "Field1");

    //     vm.expectRevert(ErrorSCR.InvalidCompanyInfo.selector);
    //     scr.createSmartCompany(
    //         scid,
    //         scImplementation,
    //         legalEntityCode,
    //         companyName,
    //         dateOfIncorporation,
    //         jurisdiction,
    //         entityType,
    //         scExtraParams,
    //         otherInfo,
    //         executionMemberAccounts,
    //         scsAddresses,
    //         scsExtraParams
    //     );
    // }

    // function testSetServiceFactory_Success() public {
    //     address newFactory = address(0x456);
    //     vm.prank(admin);
    //     scr.setServiceFactory(newFactory);
    //     assertEq(scr.getServiceFactory(), newFactory, "Service factory should be updated");
    // }

    // function testSetServiceFactory_Fail_NotAdmin() public {
    //     address newFactory = address(0x456);
    //     vm.prank(user1);
    //     vm.expectRevert("AccessControl: account is missing role");
    //     scr.setServiceFactory(newFactory);
    // }
}
