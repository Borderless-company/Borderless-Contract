// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Whitelist} from "src/Whitelist/Whitelist.sol";
import {RegisterBorderlessCompany} from "src/Register/RegisterBorderlessCompany.sol";
import {EventRegisterBorderlessCompany} from "src/interfaces/Register/EventRegisterBorderlessCompany.sol";
import {ErrorRegisterBorderlessCompany} from "src/interfaces/Register/ErrorRegisterBorderlessCompany.sol";
import {IBorderlessCompany} from "src/BorderlessCompany.sol";
import {FactoryPool} from "src/FactoryPool/FactoryPool.sol";
import {EventFactoryPool} from "src/interfaces/FactoryPool/EventFactoryPool.sol";

/// Note: FactoryService Templateのテスト用コントラクト
import {FactoryServiceTemplate} from "src/FactoryPool/FactoryServices/FactoryServiceTemplate.sol";

contract TestFactoryPool is Test {
    FactoryPool fp;
    RegisterBorderlessCompany rbc;
    IBorderlessCompany ibc;
    Whitelist wl;
    FactoryServiceTemplate fst;

    address owner;
    address exMember;
    address admin;
    address dummy;

    // -- setup companyInfo param -- //
    bytes companyID;
    bytes establishmentDate;
    bool confirmed;

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
        // TODO: IRegisterBorderlessCompanyのインターフェースを作成する
        rbc.setFactoryPool(address(fp));

        // -- 1-5. 各Serviceリリース用のFacotryのデプロイ -- //
        // Note: FactoryServiceTemplateのデプロイ(Sample用)
        fst = new FactoryServiceTemplate(address(rbc));

        vm.stopPrank();
    }

    /**
     * @dev 1.OK: FactoryPoolコントラクトにより、Borderless.companyのサービスコントラクトを起動するテストケース
     * - createBorderlessCompany
     * - activate
     * - getService
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
    function test_Success_FactoryPoolService_createBorderlessCompany_byExManaer() public {
        // -- test用セットアップ -- //
        bool started;
        address companyAddress;

        // -- test前の初期値確認 -- //
        assertTrue(keccak256(abi.encodePacked(companyID)) == keccak256(abi.encodePacked("")));
        assertTrue(keccak256(abi.encodePacked(establishmentDate)) == keccak256(abi.encodePacked("")));
        assertTrue(started == confirmed);

        // -- 0. サービス機能リリースと活性化 -- //
        vm.startPrank(owner);

        // -- 0-1. `FactoryServiceTemplate`コントラクトのデプロイ(サービスリリース) -- //
        fst = new FactoryServiceTemplate(address(rbc));

        // -- 0-2. `FactoryPool`コントラクトへ、`FactoryServiceTemplate`のアドレス登録 -- //
        vm.expectEmit(true, true, false, false);
        emit EventFactoryPool.NewService(address(fst), 1);
        fp.setService(address(fst));

        // -- 0-3. `FactoryPool`コントラクトへ登録した、`FactoryServiceTemplate`サービス状態をOnlineへ更新 -- //
        vm.expectEmit(true, true, false, false);
        emit EventFactoryPool.UpdateService(address(fst), 1, true);
        fp.updateService(address(fst), 1, true);

        // 0. `Whitelist`コントラクトへ、サービスを利用予約する業務執行社員（代表社員）を登録する。
        wl.addToWhitelist(exMember);

        vm.stopPrank();
        
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

        // -- 起動（設立）したBorderless.companyでのコントラクト実行テスト -- //
        admin = exMember; // 業務執行社員・代表社員
        vm.startPrank(admin);

        // 1. 新しい`BorderlessCompany`(Borderless.company)コントラクトの機能を、admin(`exMember`)が実行できることを確認する
        ibc = IBorderlessCompany(companyAddress);
        assertTrue(ibc.callAdmin());

        // -- test end -- //
        vm.stopPrank();
    }
}
