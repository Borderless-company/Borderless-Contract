// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

interface IWhitelist { // Note: IWhitelist is an feature interface
    /**
    * @dev ホワイトリストにアカウントを追加する外部公開関数
    * @notice オーナーのみがこの関数を呼び出せます
    * - onlyOwner モディファイアを使用して、オーナーのみがこの関数を呼び出せるようにします
    * @param account_ 追加するアカウントのアドレス
    * @return listed_ アカウントがリストに追加されたかどうかのブール値
    */
    function addToWhitelist(address account_) external returns(bool listed_);

    /**
    * @dev 指定されたアカウントがホワイトリストに含まれているかを確認する外部公開関数
    * @notice オーナーのみがこの関数を呼び出せます
    * - onlyOwner モディファイアを使用して、オーナーのみがこの関数を呼び出せるようにします
    * @param account_ 確認するアカウントのアドレス
    * @return listed_ アカウントがリストに含まれているかどうかのブール値
    */
    function isWhitelisted(address account_) external returns(bool listed_);

    /**
    * @dev 指定されたアカウントがホワイトリストに含まれているかを確認する外部公開関数
    * @notice オーナー以外もこの関数を呼び出せます
    * @return listed_ アカウントがリストに含まれているかどうかのブール値
    */
    function isWhitelisted() external returns(bool listed_);
}

interface EventWhitelist { // Note: EventWhitelist is an Event interface
    /**
    * @dev 新しい予約者が追加されたときに発生するイベント
    * @param caller_ イベントを発生させた呼び出し元のアドレス
    * @param account_ 新しく予約されたアカウントのアドレス
    */
    event NewReserver(address indexed caller_, address indexed account_);
}

interface ErrorWhitelist { // Note: ErrorWhitelist is an Error interface
    /**
    * @dev 無効なアドレスが提供された場合に発生するエラー
    * @param account_ 無効なアドレスとして提供されたアカウント
    */
    error InvalidAddress(address account_);

    /**
    * @dev 既に予約済みのアカウントが提供された場合に発生するエラー
    * @param account_ 既に予約されたアカウント
    */
    error ReserverAlready(address account_);

    /**
    * @dev ホワイトリストにアカウントを追加できなかった場合に発生するエラー
    * @param account_ ホワイトリストに追加しようとしたが失敗したアカウント
    */
    error DoNotToAddWhitelist(address account_);
}

contract Whitelist is IWhitelist, EventWhitelist, ErrorWhitelist {
    address private _owner;
    mapping(address account_ => bool listed_) private _whitelist;
    
    constructor() {
        _owner = msg.sender;
    }
    
    function addToWhitelist(address account_) external override onlyOwner returns(bool listed_) {
        if(account_ == address(0)) revert InvalidAddress(account_);
        if(_isWhitelisted(account_)) revert ReserverAlready(account_);

        listed_ = _addToWhitelist(account_);
    }

    function _addToWhitelist(address account_) internal returns(bool listed_) {
        _whitelist[account_] = true;
        
        if(_isWhitelisted(account_)) {
            emit NewReserver(msg.sender, account_);

            listed_ = true;
        } else {
            revert DoNotToAddWhitelist(account_);
        }
    }
    
    function isWhitelisted(address account_) external view override onlyOwner returns(bool listed_){
        if(account_ == address(0)) revert InvalidAddress(account_);

        listed_ = _isWhitelisted(account_);
    }

    function isWhitelisted() external view override returns(bool listed_){
        listed_ = _isWhitelisted(msg.sender);
    }

    function _isWhitelisted(address account_) internal view returns(bool listed_){
        listed_ = _whitelist[account_];
    }

    modifier onlyOwner() {
        require(msg.sender == _owner, "Error: Whitelist/Only-Owner");
        _;
    }
}
