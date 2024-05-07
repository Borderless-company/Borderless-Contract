// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Reserve} from "src/Reserve/Reserve.sol";
import {EventReserve} from "src/interfaces/Reserve/EventReserve.sol";
import {ErrorReserve} from "src/interfaces/Reserve/ErrorReserve.sol";

contract TestReserve is Test {
    Reserve rs;
    address owner;
    address reserver;
    address dummy;

    function setUp() public {
        owner = makeAddr("OverlayAdmin");
        reserver = makeAddr("Queen");

        vm.prank(address(owner));
        rs = new Reserve();
    }

    // =================== Test Cases ===================
    // OK: ホワイトリストにアカウント追加の成功テストケース
    // 1. コントラクトオーナーにより、ホワイトリストにアカウント追加が成功することを確認する。
    // NG: ホワイトリストにアカウント追加の失敗テストケース
    // 2. コントラクトオーナーにより、ホワイトリストにアカウント追加が失敗ケースを確認する。
    // 3. dummyコントラクトオーナーにより、ホワイトリストにアカウント追加が失敗ケースを確認する。
    // =================================================

    /**
     * @dev 1.OK: ホワイトリストにアカウント追加の成功テストケース
     * テストケースに含まれるオペレーション:
     * 1. ホワイトリストに予約者のアカウントを追加する。
     * 2. ホワイトリストへ予約者アカウント追加が成功したことを確認する。
     * @notice テストケースの実行には、コントラクト実行者が必要です。
     * 1. `owner` に `OverlayAdmin` を指定してコントラクトを実行します。
     * 2. `reserver` に `Queen`を指定してホワイトリストに追加します。
     */
    function test_Success_Reserve_reservation_ByOwner() public {
        // -- test用セットアップ -- //
        bool listed;

        // -- test start コントラクト実行者 -- //
        vm.startPrank(owner);

        // 1. ホワイトリストに予約者アカウントが存在していないことを確認する
        assertTrue(!rs.isWhitelisted(reserver));
        
        // 2. コントラクトオーナーが、ホワイトリストに予約者アカウントを追加する
        // 予約者がホワイトリストに登録されたイベントが発生することを確認する
        vm.expectEmit(true, true, false, false);
        emit EventReserve.NewReserver(address(reserver), 1);
        listed = rs.reservation(reserver);

        // 3. listedがtrueであることを確認する
        assertTrue(listed);

        // 4. 登録した予約契約アカウントがホワイトリストに含まれていることを確認する
        assertTrue(rs.isWhitelisted(reserver));

        // 5. 予約者数のインデックスを取得する
        uint256 index = rs.lastIndexOf();
        assertTrue(index == 1);

        // 6. 予約者のアドレスを取得する
        address reserver_ = rs.reserverOf(index);
        assertTrue(reserver_ == reserver);

        // 7. 全予約者のアドレスを取得する
        address[] memory reservers = rs.reserversOf();
        assertTrue(reservers.length == 1);
        assertTrue(reservers[0] == reserver);

        // -- test end -- //
        vm.stopPrank();
    }

    /**
     * @dev 2. NG: ホワイトリストにアカウント追加の失敗テストケース
     * テストケースに含まれるオペレーション:
     * 1. ホワイトリストに予約者のアカウントを追加する。
     * 2. ホワイトリストへ予約者アカウント追加が失敗したことを確認する。
     * @notice テストケースの実行には、コントラクト実行者が必要です。
     * 1. `owner` に `OverlayAdmin` を指定してコントラクトを実行します。
     * 2. `reserver`に、不正なアドレスを指定してリバートチェックをします
     * - address(0)アカウントであるケースのリバートチェックをします
     * - 登録済みの予約アカウントであるケースのリバートチェックをします 
     */
    function test_Fail_Reserve_reservation_ByOwner() public {
        // -- test用セットアップ -- //
        bool listed;

        // -- test start コントラクト実行者 -- //
        vm.startPrank(owner);

        // 1. ホワイトリストに予約者アカウントが存在していないことを確認する
        assertTrue(!rs.isWhitelisted(address(reserver)));
        
        // 2. コントラクトオーナーが、ホワイトリストに予約者アカウントを追加する
        listed = rs.reservation(address(reserver));

        // 3. listedがtrueであることを確認する
        assertTrue(listed);

        // 4. 登録した予約アカウントがホワイトリストに含まれていることを確認する
        assertTrue(rs.isWhitelisted(address(reserver)));

        // -- Error-Handling check -- //

        // 1. dummy == address(0)アカウントはリバートされることを確認する
        vm.expectRevert(
            abi.encodeWithSelector(
                ErrorReserve.InvalidAddress.selector,
                address(dummy)
            )
        );
        rs.isWhitelisted(address(dummy));

        // 2. address(0)アカウントはリバートされることを確認する
        vm.expectRevert(
            abi.encodeWithSelector(
                ErrorReserve.InvalidAddress.selector,
                address(0)
            )
        );
        rs.reservation(address(0));

        // 3. ホワイトリストに登録済みのアカウントはリバートされることを確認する
        vm.expectRevert(
            abi.encodeWithSelector(
                ErrorReserve.AlreadyReserve.selector,
                address(reserver)
            )
        );
        rs.reservation(reserver);

        // 4. ホワイトリスト登録失敗は、リバートされることを確認する
        // Note: 本ケースは、意図的にfalseをつくることで、異常系のリバートチェックを行っています。
        // - 特殊ケースに伴い、コメントアウトしています。
        // vm.expectRevert(
        //     abi.encodeWithSelector(
        //         ErrorReserve.DoNotToAddWhitelist.selector,
        //         address(reserver)
        //     )
        // );
        // rs.reservation(reserver);

        // -- test end -- //
        vm.stopPrank();
    }

    // /**
    //  * @dev 3. NG: ホワイトリストにアカウント追加の失敗テストケース
    //  * テストケースに含まれるオペレーション:
    //  * 1. ホワイトリストに予約者のアカウントを追加する。
    //  * 2. ホワイトリストへ予約者アカウント追加ができていないことを確認する。
    //  * @notice テストケースの実行には、コントラクト実行者が必要です。
    //  * 1. `owner` に `dummy` を指定してコントラクトを実行します。
    //  * 2. ランダムなアドレスを指定した`reserver`をホワイトリストに追加します。 
    //  */
    function test_Fail_Reserve_reservation_ByDummyOwner() public {
        // -- test用セットアップ -- //
        bool listed;
        dummy = makeAddr("Rabbit");

        // -- test start コントラクト実行者 -- //
        vm.startPrank(dummy);

        // 1. dummyコントラクトオーナーが、ホワイトリストに予約者アカウントを追加できないことを確認する
        vm.expectRevert(bytes("Error: Reserve/Only-Admin"));
        listed = rs.reservation(reserver);

        // 2. listedがfalseであることを確認する
        assertTrue(!listed);

        // 3. dummyの呼び出し者は、自身のアドレスによりホワイトリストに含まれていることか確認できる
        // Note: このケースでは、reserverがホワイトリストに含まれていないことを確認する
        assertTrue(!rs.isWhitelisted(reserver));

        // -- test end -- //
        vm.stopPrank();
    }
}