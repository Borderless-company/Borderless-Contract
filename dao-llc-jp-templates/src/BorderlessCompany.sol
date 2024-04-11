// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

// Note: 暫定的にIBorderlessCompanyコントラクトを作成
// TODO: 正規に、ディレクトリとソースコード整理をする
interface IBorderlessCompany {
    function callAdmin() external returns(bool);
}

// Note: 暫定的にIBorderlessCompanyコントラクトを作成
// TODO: 正規に、ディレクトリとソースコード整理をする
contract BorderlessCompany is IBorderlessCompany {
    address private _admin;

    // TODO: Whitelistコントラクトを用いたアドレスのホワイトリスト制御を実装する
    constructor(address admin_) {
        _admin = admin_;
    }

    // TODO: 削除する機能（テスト用feature）
    function callAdmin() external view override onlyAdmin() returns(bool) {
        return true;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Error: Register/Only-Admin");
        _;
    }
}
