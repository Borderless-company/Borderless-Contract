// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Whitelist} from "src/Whitelist/Whitelist.sol";
import {ErrorWhitelist} from "src/interfaces/Whitelist/ErrorWhitelist.sol";

contract TestWhitelist is Test {
    Whitelist wl;
    address owner;
    address reserver;
    address dummy;

    function setUp() public {
        owner = makeAddr("OverlayAdmin");
        reserver = makeAddr("Queen");

        vm.prank(address(owner));
        wl = new Whitelist();
    }

    /**
     * @dev OK: ホワイトリストにアカウント追加の成功テストケース
     * テストケースに含まれるオペレーション:
     * 1. ホワイトリストに予約者のアカウントを追加する。
     * 2. ホワイトリストへ予約者アカウント追加が成功したことを確認する。
     * @notice テストケースの実行には、コントラクト実行者が必要です。
     * 1. `owner` に `OverlayAdmin` を指定してコントラクトを実行します。
     * 2. `reserver` に `Queen`を指定してホワイトリストに追加します。
     */
    function test_Success_Whitelist_addToWhitelist_ByOwner() public {
        // -- test用セットアップ -- //
        bool listed;

        // -- test start コントラクト実行者 -- //
        vm.startPrank(owner);

        // 1. ホワイトリストに予約者アカウントが存在していないことを確認する
        assertTrue(!wl.isWhitelisted(reserver));
        
        // 2. コントラクトオーナーが、ホワイトリストに予約者アカウントを追加する
        listed = wl.addToWhitelist(reserver);

        // 3. listedがtrueであることを確認する
        assertTrue(listed);

        // 4. 登録した予約アカウントがホワイトリストに含まれていることを確認する
        assertTrue(wl.isWhitelisted(reserver));

        // -- test end -- //
        vm.stopPrank();
    }

    /**
     * @dev NG: ホワイトリストにアカウント追加の失敗テストケース
     * テストケースに含まれるオペレーション:
     * 1. ホワイトリストに予約者のアカウントを追加する。
     * 2. ホワイトリストへ予約者アカウント追加が失敗したことを確認する。
     * @notice テストケースの実行には、コントラクト実行者が必要です。
     * 1. `owner` に `OverlayAdmin` を指定してコントラクトを実行します。
     * 2. `reserver`に、不正なアドレスを指定してリバートチェックをします
     * - address(0)アカウントであるケースのリバートチェックをします
     * - 登録済みの予約アカウントであるケースのリバートチェックをします 
     */
    function test_Fail_Whitelist_addToWhitelist_ByOwner() public {
        // -- test用セットアップ -- //
        bool listed;

        // -- test start コントラクト実行者 -- //
        vm.startPrank(owner);

        // 1. ホワイトリストに予約者アカウントが存在していないことを確認する
        assertTrue(!wl.isWhitelisted(address(reserver)));
        
        // 2. コントラクトオーナーが、ホワイトリストに予約者アカウントを追加する
        listed = wl.addToWhitelist(address(reserver));

        // 3. listedがtrueであることを確認する
        assertTrue(listed);

        // 4. 登録した予約アカウントがホワイトリストに含まれていることを確認する
        assertTrue(wl.isWhitelisted(address(reserver)));

        // -- Error check -- //

        // 1. address(0)アカウントはリバートされることを確認する
        vm.expectRevert(
            abi.encodeWithSelector(
                ErrorWhitelist.InvalidAddress.selector,
                address(0)
            )
        );
        wl.isWhitelisted(address(0));

        // 2. address(0)アカウントはリバートされることを確認する
        vm.expectRevert(
            abi.encodeWithSelector(
                ErrorWhitelist.InvalidAddress.selector,
                address(0)
            )
        );
        wl.addToWhitelist(address(0));

        // 2. ホワイトリストに登録済みのアカウントはリバートされることを確認する
        vm.expectRevert(
            abi.encodeWithSelector(
                ErrorWhitelist.ReserverAlready.selector,
                address(reserver)
            )
        );
        wl.addToWhitelist(reserver);

        // 3. ホワイトリスト登録失敗は、リバートされることを確認する
        // Note: 本ケースは、意図的にfalseをつくることで、異常系のリバートチェックを行っています。
        // - 特殊ケースに伴い、コメントアウトしています。
        // vm.expectRevert(
        //     abi.encodeWithSelector(
        //         ErrorWhitelist.DoNotToAddWhitelist.selector,
        //         address(reserver)
        //     )
        // );
        // wl.addToWhitelist(reserver);

        // -- test end -- //
        vm.stopPrank();
    }

    /**
     * @dev NG: ホワイトリストにアカウント追加の失敗テストケース
     * テストケースに含まれるオペレーション:
     * 1. ホワイトリストに予約者のアカウントを追加する。
     * 2. ホワイトリストへ予約者アカウント追加ができていないことを確認する。
     * @notice テストケースの実行には、コントラクト実行者が必要です。
     * 1. `owner` に `dummy` を指定してコントラクトを実行します。
     * 2. ランダムなアドレスを指定した`reserver`をホワイトリストに追加します。 
     */
    function test_Fail_Whitelist_addToWhitelist_ByDummyOwner(address account_) public {
        // -- test用セットアップ -- //
        bool listed;
        dummy = makeAddr("Rabbit");
        reserver = account_;

        // -- test start コントラクト実行者 -- //
        vm.startPrank(dummy);

        // 1. コントラクトオーナーのみ、ホワイトリストに予約者アカウントを指定して確認ができる
        vm.expectRevert(bytes("Error: Whitelist/Only-Owner"));
        wl.isWhitelisted(reserver);

        // 2. ホワイトリストに予約者アカウントが存在していないことを確認する
        assertTrue(!wl.isWhitelisted());

        // 3. コントラクトオーナーが、ホワイトリストに予約者アカウントを追加する
        vm.expectRevert(bytes("Error: Whitelist/Only-Owner"));
        listed = wl.addToWhitelist(reserver);

        // 4. listedがtrueであることを確認する
        assertTrue(!listed);

        // 5. 登録した予約アカウントがホワイトリストに含まれていることを確認する
        assertTrue(!wl.isWhitelisted());

        // -- test end -- //
        vm.stopPrank();
    }
}