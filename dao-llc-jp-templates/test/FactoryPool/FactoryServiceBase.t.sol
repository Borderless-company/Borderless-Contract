// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Whitelist} from "src/Whitelist/Whitelist.sol";
import {RegisterBorderlessCompany} from "src/Register/RegisterBorderlessCompany.sol";
import {EventRegisterBorderlessCompany} from "src/interfaces/Register/EventRegisterBorderlessCompany.sol";
import {FactoryPool} from "src/FactoryPool/FactoryPool.sol";
import {FactoryServiceBase} from "src/FactoryPool/FactoryServices/FactoryServiceBase.sol";

/// @title Test sample smart contract for Borderless.company service
contract SampleService {
    address private _admin;
    address private _company;

    constructor(address admin_, address company_) {
        _admin = admin_;
        _company = company_;
    }

    function callAdmin() public view onlyService returns (bool called_) {
        called_ = true;
    }

    modifier onlyService() {
        require(_validateCaller(), "Error: SampleService/Invalid-Caller");
        _;
    }

    function _validateCaller() internal view returns (bool called_) {
        if(msg.sender == _admin && msg.sender == _company) called_ = true;
    }
}

/// @title Test factory sample smart contract for Borderless.company service
contract BaseSampleFactory is FactoryServiceBase {
    address private _admin;
    address private _company;

    constructor(address register_) FactoryServiceBase(register_) {}

    function activate(address admin_, address company_, uint256 serviceID_) external override onlyRegister returns (address service_) {
        service_ = _activate(admin_, company_, serviceID_);
    }

    function _activate(address admin_, address company_, uint256 serviceID_) internal override returns (address service_) {
        // Note: common service setup
        SampleService service = new SampleService(admin_, company_);

        if(address(service) == address(0)) revert DoNotActivateService(admin_, company_, serviceID_);

        emit ActivateBorderlessService(admin_, address(service), serviceID_);

        service_ = address(service);
    }
}

contract TestFactoryServiceBase is Test {
    Whitelist wl;
    RegisterBorderlessCompany rbc;
    FactoryPool fp;
    BaseSampleFactory bsf;

    address owner;
    address exMember;
    address admin;
    address dummy;

    // -- setup companyInfo param -- //
    bytes companyID;
    bytes establishmentDate;
    bool confirmed;

    function setUp() public {
        owner = makeAddr("OverlayAdmin");
        exMember = makeAddr("Queen");

        vm.startPrank(owner);

        // -- 1-1. Whitelistのデプロイ -- //
        wl = new Whitelist();
        // -- 1-2. RegisterBorderlessCompanyのデプロイ -- //
        rbc = new RegisterBorderlessCompany(address(wl));
        // -- 1-3. FactoryPoolのデプロイ -- //
        fp = new FactoryPool(address(rbc));
        // -- 1-4. RegisterBorderlessCompanyにFactoryPoolのアドレス登録 -- //
        rbc.setFactoryPool(address(fp));

        // -- 2-1. FactoryServiceのデプロイ -- //
        bsf = new BaseSampleFactory(address(rbc));
        // -- Set Service Address -- //
        fp.setService(address(bsf), 1); // index = 1 GovernanceService
        // -- Activate Service -- //
        fp.updateService(address(bsf), 1, true); // index = 1 GovernanceService

        // 0. `Whitelist`コントラクトへ、サービスを利用予約する業務執行社員（代表社員）を登録する。
        wl.addToWhitelist(exMember);

        vm.stopPrank();
    }

    function test_Success_FactoryBase_createService() public {
        // -- test用セットアップ -- //
        bool started;
        address companyAddress;

        // -- test start コントラクト実行者 -- //
        vm.startPrank(exMember);

        // 1. Borderless.companyのためのCompanyInfoを入力する
        companyID = "0x-borderless-company-id";
        establishmentDate = "YYYY-MM-DD HH:MM:SS";
        confirmed = true;

        // 2. Borderless.companyを起動する
        // MEMO: contractのaddressはテストログより参照した値です
        vm.expectEmit(true, true, true, false);
        emit EventRegisterBorderlessCompany.NewBorderlessCompany(address(exMember), address(0x5fadc320561EED0887d2A7df9C6Dd71d94655C0b), 1);

        (started, companyAddress) = rbc.createBorderlessCompany(companyID, establishmentDate, confirmed);

        // 3. Borderless.companyの起動（設立）が成功したことを確認する
        assertTrue(started);

        vm.stopPrank();
    }
}
