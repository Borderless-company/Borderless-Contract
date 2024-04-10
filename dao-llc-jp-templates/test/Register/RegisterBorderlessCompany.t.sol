// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {RegisterBorderlessCompany, IBorderlessCompany} from "src/Register/RegisterBorderlessCompany.sol";

contract TestRegisterBorderlessCompany is Test {
    RegisterBorderlessCompany rbc;
    IBorderlessCompany ibc;
    address owner;
    address exMember;
    address admin;

    // -- setup companyInfo param -- //
    bytes companyID;
    bytes establishmentDate;
    bool confirmed;

    function setUp() public {
        owner = makeAddr("OverlayAdmin");
        exMember = makeAddr("Queen");

        rbc = new RegisterBorderlessCompany();
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
     * 1. サービス予約を完了した業務執行社員（代表社員）により、Borderless.companyのためのCompanyInfoを入力する。
     * 2. サービス予約を完了した業務執行社員（代表社員）により、Borderless.companyを起動する
     * 3. 新しい`BorderlessCompany`(Borderless.company)コントラクトが起動（設立）が成功したことを確認する。
     * @notice テストケースの実行には、コントラクト実行者が必要です。
     * 1. `owner` に `OverlayAdmin` を指定してコントラクトを実行します。
     * 2. `exMember` に `Queen`を指定して実行します。
     * 3. `admin` は、 `exMember`(Queen)を代入して実行します。
     */
    function test_Success_RegisterBorderlessCompany_createBorderlessCompany_byExManaer() public {
        // -- test用セットアップ -- //
        bool started;
        address companyAddress;

        // -- test前の初期値確認 -- //
        assertTrue(keccak256(abi.encodePacked(companyID)) == keccak256(abi.encodePacked("")));
        assertTrue(keccak256(abi.encodePacked(establishmentDate)) == keccak256(abi.encodePacked("")));
        assertTrue(started == confirmed);

        // -- test start コントラクト実行者 -- //
        vm.startPrank(exMember);

        // 1. Borderless.companyのためのCompanyInfoを入力する
        companyID = "0x-borderless-company-id";
        establishmentDate = "YYYY-MM-DD HH:MM:SS";
        confirmed = true;

        // 2. Borderless.companyを起動する
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
