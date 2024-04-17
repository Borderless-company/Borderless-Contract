// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Whitelist} from "src/Whitelist/Whitelist.sol";
import {RegisterBorderlessCompany} from "src/Register/RegisterBorderlessCompany.sol";
import {EventRegisterBorderlessCompany} from "src/interfaces/Register/EventRegisterBorderlessCompany.sol";
import {ErrorRegisterBorderlessCompany} from "src/interfaces/Register/ErrorRegisterBorderlessCompany.sol";
import {IBorderlessCompany} from "src/BorderlessCompany.sol";
import {FactoryPool} from "src/FactoryPool/FactoryPool.sol";

/// @title Test smart contract for Borderless.company service
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
        require(_validateCaller(), "SampleService: Invalid-Caller");
        _;
    }

    function _validateCaller() internal view returns (bool called_) {
        if(msg.sender == _admin && msg.sender == _company) called_ = true;
    }
}

/// @title common interface for factory service
interface IFactoryService {
    function setup(address admin_, address company_, uint256 serviceID_) external returns (address service_);
}

/// @title common event interface for factory service
interface EventFactoryService {
    event SetupBorderlessService(address indexed admin_, address indexed service, uint256 indexed serviceID);
}

/// @title Test factory smart contract for Borderless.company service
contract FactorySampleService is IFactoryService, EventFactoryService {
    address private _owner;
    address private _register;

    constructor(address register_) {
        _owner = msg.sender;
        _register = register_;
    }

    function setup(address admin_, address company_, uint256 serviceID_) external override onlyRegister returns (address service_) {
        /// Note: common service setup
        SampleService service = new SampleService(admin_, company_);

        emit SetupBorderlessService(admin_, address(service), serviceID_);

        service_ = address(service);
    }

    modifier onlyRegister() {
        require(msg.sender == _register, "FactoryService: Only-Register");
        _;
    }
}

contract TestFactoryPool is Test {
    FactoryPool fp;
    RegisterBorderlessCompany rbc;
    IBorderlessCompany ibc;
    Whitelist wl;

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
        fp = new FactoryPool();

        wl = new Whitelist();

        rbc = new RegisterBorderlessCompany(address(wl));

        vm.stopPrank();
    }

    // =================== Test Cases ===================
    // OK: FactoryPoolコントラクトにより、Borderless.companyのサービスコントラクトを起動するテストケース
    // 1. `OverlayAG Admin` オペレーションによるデプロイ（サービス提供者）
    //    1. `Whitelist`コントラクトのデプロイ
    //       1. `Whitelist`は、`業務執行社員・代表社員`のホワイトリスト管理と、その登録機能を有する
    //    2. `FactoryPool`コントラクトのデプロイする。
    //       1. `FactoryPool`は、`各Serviceリリース用のFacotry`の ID・アドレス管理と、その登録機能を有する
    //    3. `Register`コントラクトのデプロイし、その時に、`Whitelist`, `FactoryPool`コントラクトのアドレスを登録する。
    //    4. `各Serviceリリース用のFacotry`コントラクトをデプロイし、その時に、`Register`コントラクトのアドレスを登録する。
    //    5. `FactoryPool`コントラクトへデプロイした、`各Serviceリリース用のFacotry`コントラクトのアドレスを登録する。
    //       1. `Register`コントラクトで、`createBorderlessCompany`機能をコールする時にアドレスを参照する。
    // 2. `業務執行社員・代表社員` オペレーションによるデプロイ（サービス利用者）
    //    1. `Register`コントラクトで、`createBorderlessCompany`を実行する。
    //    2. `BorderlessCompany`コントラクトが起動する。
    //    3. `FactoryPool`コントラクトより、`_services`を参照し`各Serviceリリース用のFacotry`コントラクトを実行する。
    //    4. 3 をもとに`各Serviceリリース用のFacotry`コントラクトアドレスを指定して、 `setup`により Service を起動する。
    // ===================================================

    /**
     * @dev 1.OK: Borderless.companyのサービスコントラクトの起動成功のテストケース
     * - createBorderlessCompany
     * 
     * テストケースに含まれるオペレーション:
     * 0. `Whitelist`コントラクトへ、サービスを利用予約する業務執行社員（代表社員）を登録する。
     * 1. サービス予約を完了した業務執行社員（代表社員）により、Borderless.companyのためのCompanyInfoを入力する。
     * 2. サービス予約を完了した業務執行社員（代表社員）により、Borderless.companyを起動する
     * 3. 新しい`BorderlessCompany`(Borderless.company)コントラクトが起動（設立）が成功したことを確認する。
     * 4. 新しい`BorderlessCompany`(Borderless.company)コントラクトの機能実行ができることを確認する。
     * @notice テストケースの実行には、コントラクト実行者が必要です。
     * 1. `owner` に `OverlayAdmin` を指定してコントラクトを実行します。
     * 2. `exMember` に `Queen`を指定して実行します。
     * 3. `admin` は、 `exMember`(Queen)を代入して実行します。
     */
    function test_Success_FactoryPool_createBorderlessCompany_byExManaer() public {
        // -- test用セットアップ -- //
        // bool started;
        // address companyAddress;

        // // -- test前の初期値確認 -- //
        // assertTrue(keccak256(abi.encodePacked(companyID)) == keccak256(abi.encodePacked("")));
        // assertTrue(keccak256(abi.encodePacked(establishmentDate)) == keccak256(abi.encodePacked("")));
        // assertTrue(started == confirmed);

        // // 0. `Whitelist`コントラクトへ、サービスを利用予約する業務執行社員（代表社員）を登録する。
        // vm.prank(owner);
        // wl.addToWhitelist(exMember);
        
        // -- test start コントラクト実行者 -- //
        vm.startPrank(exMember);

        // // 1. Borderless.companyのためのCompanyInfoを入力する
        // companyID = "0x-borderless-company-id";
        // establishmentDate = "YYYY-MM-DD HH:MM:SS";
        // confirmed = true;

        // // 2. Borderless.companyを起動する
        // // MEMO: contractのaddressはテストログより参照した値です
        // vm.expectEmit(true, true, true, false);
        // emit EventRegisterBorderlessCompany.NewBorderlessCompany(address(exMember), address(0x5fadc320561EED0887d2A7df9C6Dd71d94655C0b), 1);

        // (started, companyAddress) = rbc.createBorderlessCompany(companyID, establishmentDate, confirmed);

        // // 3. Borderless.companyの起動（設立）が成功したことを確認する
        // assertTrue(started);

        // vm.stopPrank();

        // // -- 起動（設立）したBorderless.companyでのコントラクト実行テスト -- //
        // admin = exMember; // 業務執行社員・代表社員
        // vm.startPrank(admin);

        // // 1. 新しい`BorderlessCompany`(Borderless.company)コントラクトの機能を、admin(`exMember`)が実行できることを確認する
        // ibc = IBorderlessCompany(companyAddress);
        // assertTrue(ibc.callAdmin());

        // -- test end -- //
        vm.stopPrank();
    }
}
