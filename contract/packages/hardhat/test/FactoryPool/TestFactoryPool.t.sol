// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {Reserve} from "../../contracts/Reserve/Reserve.sol";
import {RegisterBorderlessCompany} from "../../contracts/Register/RegisterBorderlessCompany.sol";
import {FactoryPool} from "../../contracts/FactoryPool/FactoryPool.sol";
import {EventRegisterBorderlessCompany} from "../../contracts/Register/interfaces/EventRegisterBorderlessCompany.sol";
import {IBorderlessCompany} from "../../contracts/BorderlessCompany.sol";
import {FactoryServiceBase} from "../../contracts/FactoryPool/FactoryServices/FactoryServiceBase.sol";
import {Upgrades, Options} from "@openzeppelin-foundry-upgrades/Upgrades.sol";
import {BorderlessCompany} from "../../contracts/BorderlessCompany.sol";
import {FactoryPool} from "../../contracts/FactoryPool/FactoryPool.sol";
import {BaseSampleFactory} from "../../contracts/Mock/BaseSampleFactory.sol";
import "forge-std/console.sol";

contract TestFactoryPool is Test {
    Reserve rs;
    RegisterBorderlessCompany rbc;
    FactoryPool fp;
    IBorderlessCompany ibc;
    BaseSampleFactory bsf; // Note: SampleService Factory contract for test

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
    //    1. `Reserve`コントラクトのデプロイ
    //       1. `Reserve`は、`業務執行社員・代表社員`のホワイトリスト管理と、その登録機能を有する
    //    2. `FactoryPool`コントラクトのデプロイする。
    //       1. `FactoryPool`は、`各Serviceリリース用のFacotry`の ID・アドレス管理と、その登録機能を有する
    //    3. `Register`コントラクトのデプロイし、その時に、`Reserve`コントラクトのアドレスを登録する。
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

        // -- オプション設定 -- //
        // safeチェックを無視する
        Options memory opts;
        opts.unsafeSkipAllChecks = true;

        // -- 1-1. Reserveのデプロイ -- //
        // rs = new Reserve();
        rs = Reserve(Upgrades.deployUUPSProxy("Reserve.sol", "", opts));
        rs.initialize();
        // -- 1-2. RegisterBorderlessCompanyのデプロイ -- //
        address borderlessCompanyImplementation = address(
            new BorderlessCompany()
        );

        rbc = RegisterBorderlessCompany(
            Upgrades.deployUUPSProxy(
                "RegisterBorderlessCompany.sol",
                abi.encodeCall(
                    RegisterBorderlessCompany.initialize,
                    (borderlessCompanyImplementation, address(rs))
                ),
                opts
            )
        );
        // -- 1-3. FactoryPoolのデプロイ -- //
        address beacon = Upgrades.deployBeacon("FactoryPool.sol", owner);
        fp = FactoryPool(
            Upgrades.deployBeaconProxy(
                beacon,
                abi.encodeCall(
                    FactoryPool.initialize,
                    (address(rbc))
                ),
                opts
            )
        );
        // -- 1-4. RegisterBorderlessCompanyにFactoryPoolのアドレス登録 -- //
        rbc.setFactoryPool(address(fp));

        // -- 2-1. FactoryServiceのデプロイ -- //
        address baseSampleFactoryImplementation = address(
            new BaseSampleFactory()
        );
        bsf = BaseSampleFactory(
            Upgrades.deployUUPSProxy(
                "BaseSampleFactory.sol",
                abi.encodeCall(
                    BaseSampleFactory.initialize,
                    (baseSampleFactoryImplementation, address(rbc))
                ),
                opts
            )
        );
        console.log("bsf", address(bsf));
        // -- Set Service Address -- //
        fp.setService(address(bsf), 1); // index = 1 GovernanceService
        // -- Activate Service -- //
        fp.updateService(address(bsf), 1, true); // index = 1 GovernanceService

        // 0. `Reserve`コントラクトへ、サービスを利用予約する業務執行社員（代表社員）を登録する。
        rs.reservation(exMember);

        // -- ラベル設定 -- //
        vm.label(address(rs), "Reserve");
        vm.label(address(rbc), "RegisterBorderlessCompany");
        vm.label(address(fp), "FactoryPool");
        vm.label(address(bsf), "BaseSampleFactory");

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
    function test_Success_FactoryPoolService_createBorderlessCompany_byExManaer()
        public
    {
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
        vm.expectEmit(true, false, true, false);
        emit EventRegisterBorderlessCompany.NewBorderlessCompany(
            address(exMember),
            address(0x5fadc320561EED0887d2A7df9C6Dd71d94655C0b),
            1
        );

        (started, companyAddress) = rbc.createBorderlessCompany(
            companyID,
            establishmentDate,
            confirmed
        );

        console.log("started: %s", started);
        console.log("companyAddress: %s", companyAddress);

        // 3. Borderless.companyの起動（設立）が成功したことを確認する
        assertTrue(started);

        vm.stopPrank();

        // -- 起動（設立）したBorderless.companyでのコントラクト実行テスト -- //
        admin = exMember; // 業務執行社員・代表社員
        vm.startPrank(admin);

        // 1. 新しい`BorderlessCompany`(Borderless.company)コントラクトの機能を、admin(`exMember`)が実行できることを確認する
        ibc = IBorderlessCompany(companyAddress);
        console.log("ibc: %s", address(ibc));
        address serviceAddress = ibc.getService(1);
        console.log("serviceAddress: %s", serviceAddress);
        assertTrue(serviceAddress != address(0));

        // -- test end -- //
        vm.stopPrank();
    }

    function test_Success_FactoryPool_admins() public {
        // -- test start コントラクト実行者 -- //
        vm.startPrank(owner);

        // 1. newAdminを追加する
        fp.addAdmin(exMember);

        // 2. newAdminが追加されたことを確認する
        assertTrue(fp.isAdmin(exMember));

        // 3. newAdminを削除する
        fp.removeAdmin(exMember);

        // 4. newAdminが削除されたことを確認する
        assertFalse(fp.isAdmin(exMember));

        // -- test end -- //
        vm.stopPrank();
    }
}
