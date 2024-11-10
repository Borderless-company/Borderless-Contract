// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {Reserve} from "../../contracts/Reserve/Reserve.sol";
import {RegisterBorderlessCompany} from "../../contracts/Register/RegisterBorderlessCompany.sol";
import {EventRegisterBorderlessCompany} from "../../contracts/Register/interfaces/EventRegisterBorderlessCompany.sol";
import {ErrorRegisterBorderlessCompany} from "../../contracts/Register/interfaces/ErrorRegisterBorderlessCompany.sol";
import {IBorderlessCompany} from "../../contracts/BorderlessCompany.sol";
import {FactoryPool} from "../../contracts/FactoryPool/FactoryPool.sol";
import {EventFactoryPool} from "../../contracts/FactoryPool/interfaces/EventFactoryPool.sol";
import {Upgrades, Options} from "@openzeppelin-foundry-upgrades/Upgrades.sol";
import {BorderlessCompany} from "../../contracts/BorderlessCompany.sol";
import {FactoryPool} from "../../contracts/FactoryPool/FactoryPool.sol";
import "forge-std/console.sol";

contract TestRegisterBorderlessCompany is Test {
    RegisterBorderlessCompany rbc;
    IBorderlessCompany ibc;
    Reserve rs;
    FactoryPool fp;

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

        // -- オプション設定 -- //
        // safeチェックを無視する
        Options memory opts;
        opts.unsafeSkipAllChecks = true;

        vm.startPrank(owner);
        rs = Reserve(Upgrades.deployUUPSProxy("Reserve.sol", "", opts));
        rs.initialize();

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

        rbc.setFactoryPool(address(fp));

        vm.stopPrank();
    }

    // =================== Test Cases ===================
    // OK: Borderless.companyのサービスコントラクトの起動成功のテストケース
    // 1. サービス予約を完了した業務執行社員（代表社員）により、BorderlessCompanyコントラクトの起動（設立）が成功することを確認する。
    // NG: Borderless.companyのサービスコントラクトの起動失敗のテストケース
    // 2. 不正な呼び出し者により、Borderless.companyのサービスコントラクト起動失敗ケースを確認する。
    //    1. ホワイトリスト未登録者は、Borderless.companyのサービスコントラクト起動できないことを確認する。
    //    2. 不正なCompanyInfoリソースは、Borderless.companyのサービスコントラクト起動できないことを確認する。
    //      a. `companyID` 登記による法人IDが存在しない
    //      b. `establishmentDate` 登記による設立日が存在しない
    //      c. `confirmed` 規約・規定に同意をしていない（false）
    // ===================================================

    /**
     * @dev 1.OK: Borderless.companyのサービスコントラクトの起動成功のテストケース
     * - createBorderlessCompany
     *
     * テストケースに含まれるオペレーション:
     * 0. `Reserve`コントラクトへ、サービスを利用予約する業務執行社員（代表社員）を登録する。
     * 1. サービス予約を完了した業務執行社員（代表社員）により、Borderless.companyのためのCompanyInfoを入力する。
     * 2. サービス予約を完了した業務執行社員（代表社員）により、Borderless.companyを起動する
     * 3. 新しい`BorderlessCompany`(Borderless.company)コントラクトが起動（設立）が成功したことを確認する。
     * 4. 新しい`BorderlessCompany`(Borderless.company)コントラクトの機能実行ができることを確認する。
     * @notice テストケースの実行には、コントラクト実行者が必要です。
     * 1. `owner` に `OverlayAdmin` を指定してコントラクトを実行します。
     * 2. `exMember` に `Queen`を指定して実行します。
     * 3. `admin` は、 `exMember`(Queen)を代入して実行します。
     */
    function test_Success_RegisterBorderlessCompany_createBorderlessCompany_byExManaer()
        public
    {
        // -- test用セットアップ -- //
        bool started;
        address companyAddress;

        // -- test前の初期値確認 -- //
        assertTrue(
            keccak256(abi.encodePacked(companyID)) ==
                keccak256(abi.encodePacked(""))
        );
        assertTrue(
            keccak256(abi.encodePacked(establishmentDate)) ==
                keccak256(abi.encodePacked(""))
        );
        assertTrue(started == confirmed);

        // 0. `Reserve`コントラクトへ、サービスを利用予約する業務執行社員（代表社員）を登録する。
        vm.prank(owner);
        rs.reservation(exMember);

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

        // 3. Borderless.companyの起動（設立）が成功したことを確認する
        assertTrue(started);

        vm.stopPrank();

        // -- 起動（設立）したBorderless.companyでのコントラクト実行テスト -- //
        admin = exMember; // 業務執行社員・代表社員
        vm.startPrank(admin);

        // 1. 新しい`BorderlessCompany`(Borderless.company)コントラクトの機能を、admin(`exMember`)が実行できることを確認する
        ibc = IBorderlessCompany(companyAddress);

        assertTrue(address(ibc) != address(0));

        // ラベル設定
        vm.label(owner, "OverlayAdmin");
        vm.label(exMember, "Queen");
        vm.label(admin, "Admin");
        vm.label(dummy, "Rabbit");
        vm.label(address(rs), "Reserve");
        vm.label(address(rbc), "RegisterBorderlessCompany");
        vm.label(companyAddress, "BorderlessCompany");

        // -- test end -- //
        vm.stopPrank();
    }

    /**
     * @dev 1.NG: 不正な呼び出し者により、Borderless.companyのサービスコントラクト起動失敗ケース
     * - createBorderlessCompany
     *
     * テストケースに含まれるオペレーション:
     * 1. サービス予約を完了していない実行者により、Borderless.companyを起動する。
     * 2. サービス予約を完了した業務執行社員（代表社員）により、不正なCompanyInfoを入力して、Borderless.companyを起動する。
     *    1. `companyID` 登記による法人IDが存在しない
     *    2. `establishmentDate` 登記による設立日が存在しない
     *    3. `confirmed` 規約・規定に同意をしていない（false）
     * @notice テストケースの実行には、コントラクト実行者が必要です。
     * 1. `owner` に `OverlayAdmin` を指定してコントラクトを実行します。
     * 2. `exMember` に `Queen`を指定して実行します。
     * 3. `admin` は、 `exMember`(Queen)を代入して実行します。
     * 4. `dummy` は、 `Rabbit`を代入して実行します。
     */
    function test_Fail_RegisterBorderlessCompany_createBorderlessCompany_byDummyExMember()
        public
    {
        // -- test用セットアップ -- //
        bool started;
        address companyAddress;
        dummy = makeAddr("Rabbit");

        // -- test前の初期値確認 -- //
        assertTrue(
            keccak256(abi.encodePacked(companyID)) ==
                keccak256(abi.encodePacked(""))
        );
        assertTrue(
            keccak256(abi.encodePacked(establishmentDate)) ==
                keccak256(abi.encodePacked(""))
        );
        assertTrue(started == confirmed);

        // -- test start コントラクト実行者 -- //
        vm.startPrank(dummy);

        // 1. サービス予約を完了していない実行者により、Borderless.companyを起動する
        vm.expectRevert(bytes("Error: Register/Only-Founder"));
        (started, companyAddress) = rbc.createBorderlessCompany(
            companyID,
            establishmentDate,
            confirmed
        );
        assertTrue(!started);

        vm.stopPrank();

        // 2. サービス予約を完了した業務執行社員（代表社員）により、不正なCompanyInfoを入力
        vm.prank(owner);
        console.log("owner", owner);
        rs.reservation(exMember);

        vm.startPrank(exMember);

        // Note: 不正なCompanyInfoを入力してテストを実行する
        companyID = "0x-borderless-company-id";
        establishmentDate = "YYYY-MM-DD HH:MM:SS";
        confirmed = false;

        vm.expectRevert(
            abi.encodeWithSelector(
                ErrorRegisterBorderlessCompany.InvalidCompanyInfo.selector,
                address(exMember)
            )
        );
        (started, companyAddress) = rbc.createBorderlessCompany(
            companyID,
            establishmentDate,
            confirmed
        );
        assertTrue(!started);

        // -- test end -- //
        vm.stopPrank();
    }

    function test_Success_Register_admins() public {
        // -- test start コントラクト実行者 -- //
        vm.startPrank(owner);

        // 1. newAdminを追加する
        rbc.addAdmin(exMember);

        // 2. newAdminが追加されたことを確認する
        assertTrue(rbc.isAdmin(exMember));

        // 3. newAdminを削除する
        rbc.removeAdmin(exMember);

        // 4. newAdminが削除されたことを確認する
        assertFalse(rbc.isAdmin(exMember));

        // -- test end -- //
        vm.stopPrank();
    }
}
