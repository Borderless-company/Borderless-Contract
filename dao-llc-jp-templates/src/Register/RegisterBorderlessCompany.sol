// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {IWhitelist} from "src/interfaces/Whitelist/IWhitelist.sol"; 

/// @title feature interface for RegisterBorderlessCompany contract
interface IRegisterBorderlessCompany { // Note: IRegisterBorderlessCompany is an feature interface
    /**
    * @dev ボーダーレス企業を作成します。
    * @param companyID_ 企業のIDです。
    * @param establishmentDate_ 企業の設立日時です。
    * @param confirmed_ 企業が確認されているかどうかです。
    * @return started_ 企業作成が開始されたかどうかを示すブール値です。
    * @return companyAddress_ 作成された企業コントラクトを示すアドレス値です。
    */
    // function createBorderlessCompany(bytes calldata companyID_, bytes calldata establishmentDate_, bool confirmed_) external returns(bool started_);
    function createBorderlessCompany(bytes calldata companyID_, bytes calldata establishmentDate_, bool confirmed_) external returns(bool started_, address companyAddress_);
}

/// @title Event interface for RegisterBorderlessCompany contract
interface EventRegisterBorderlessCompany { // Note: EventRegisterBorderlessCompany is an event interface
    /**
    * @dev 新しいBorderless.companyが作成されたことを通知するイベントです。
    * @param founder_ Borderless.companyを起動した呼び出し元のアドレスです。
    * @param company_ 新しく作成されたBorderless.companyのアドレスです。
    * @param companyIndex_ 新しく作成されたBorderless.companyのインデックスです。
    */
    event NewBorderlessCompany(address indexed founder_, address indexed company_, uint256 indexed companyIndex_);
}

/// @title Error interface for RegisterBorderlessCompany contract
interface ErrorRegisterBorderlessCompany { // Note: ErrorRegisterBorderlessCompany is an event interface
    /**
    * @dev 不正な事業リソースが提供された場合に発生するエラー
    * @param account_ 起動（設立）しようとしたが失敗したアカウント
    */
    // TODO: `account_`から`CompanyInfo`に変更する
    error InvalidCompanyInfo(address account_);

    /**
    * @dev Borderless.companyを起動（設立）できなかった場合に発生するエラー
    * @param account_ 起動（設立）しようとしたが失敗したアカウント
    */
    // TODO: `account_`から`CompanyInfo`に変更する
    error DoNotCreateBorderlessCompany(address account_);
}

contract RegisterBorderlessCompany is IRegisterBorderlessCompany, EventRegisterBorderlessCompany {
    IWhitelist private _whitelist;
    // TODO: `_owner`機能の実装をする
    address private _owner;
    // TODO: `_lastIndex`管理機能を実装する
    uint256 private _lastIndex;
    mapping (uint256 index_ => CompanyInfo companyInfo_) private _companies;

    // TODO: `CompanyInfo`データ構造をinterfaceへ移動する。
    struct CompanyInfo {
        address companyAddress;
        address founder;
        bytes companyID;
        bytes establishmentDate;
        bool confirmed;
        uint256 createAt;
        uint256 updateAt;
    }

    // TODO: constructorの実装をする
    constructor(address whitelist_) {
        _whitelist = IWhitelist(whitelist_);
    }

    // TODO: Whitelistより、`isWhitelisted`機能によるアクセスコントロールを実装する
    function createBorderlessCompany(bytes calldata companyID_, bytes calldata establishmentDate_, bool confirmed_) external override onlyFounder returns(bool started_, address companyAddress_) {
        CompanyInfo memory _info;

        if (companyID_.length == 0 || establishmentDate_.length == 0 || !confirmed_) {
            // TODO: Error-handlingを実装する
            started_ = false;
        } else {
            _info.founder = msg.sender;
            _info.companyID = companyID_;
            _info.establishmentDate = establishmentDate_;
            _info.confirmed = confirmed_;
            _info.createAt = block.timestamp;
            _info.updateAt = block.timestamp;
        }

        (started_, companyAddress_) = _createBorderlessCompany(_info);
    }

    function _createBorderlessCompany(CompanyInfo memory info_) private returns(bool started_, address companyAddress_) {
        BorderlessCompany _company = new BorderlessCompany(info_.founder);
        // TODO: Error-handlingを実装する
        info_.companyAddress = address(_company);

        _lastIndex++;
        // TODO: _lastIndexの値取得をする機能を実装する
        _companies[_lastIndex] = info_;

        emit NewBorderlessCompany(info_.founder, info_.companyAddress, _lastIndex);

        (started_, companyAddress_) = (true, info_.companyAddress);
    }

    modifier onlyFounder() {
        require(_whitelist.isWhitelisted(msg.sender) , "Error: Register/Only-Founder");
        _;
    }
}

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
        require(msg.sender == _admin, "BorderlessCompany: caller is not the admin");
        _;
    }
}
