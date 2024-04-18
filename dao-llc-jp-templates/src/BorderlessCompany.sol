// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

// Note: 暫定的にIGovernanceServiceを作成
// TODO: 正規に、ディレクトリとソースコード整理をする
interface IGovernanceService {
    function callGovernance() external returns(bool);
}
// Note: 暫定的にIGovernanceServiceを作成
// TODO: 正規に、ディレクトリとソースコード整理をする
interface ITreasuryService {
    function callTreasury() external returns(bool);
}
// Note: 暫定的にIGovernanceServiceを作成
// TODO: 正規に、ディレクトリとソースコード整理をする
interface ITokenService {
    function callToken() external returns(bool);
}

/// @title feature interface for BorderlessCompny contract
interface IBorderlessCompany { // Note: IBorderlessCompny is an feature interface
    /**
    * @dev サービスの初期設定
    * @notice Registerからのみ実行できる
    * - onlyRegister モディファイアを使用して、オーナーのみがこの関数を呼び出せるようにします
    * @param services_ 初期設定するサービスのアドレス配列
    * @return completed_ 初期設定するサービスのアドレスが設定されたかどうかのブール値
    */
    function initialService(address[] memory services_) external returns(bool completed_);

    /// @dev テスト用の機能
    function callAdmin() external returns(bool);
}

// Note: 暫定的にIBorderlessCompanyコントラクトを作成
// TODO: 正規に、ディレクトリとソースコード整理をする
contract BorderlessCompany is IBorderlessCompany {
    address private _admin;
    address private _register;
    mapping(uint256 index_ => address service_) private _services;

    constructor(address admin_, address register_) {
        _admin = admin_;
        _register = register_;
    }

    // TODO: 削除する機能（テスト用feature）
    function callAdmin() external view override onlyAdmin() returns(bool) {
        return true;
    }

    function initialService(address[] calldata services_) external override onlyRegister returns(bool completed_){
        if(_getService(1) != address(0) || _getService(2) != address(0) || _getService(3) != address(0)) revert AlreadyInitialService(msg.sender);
        
        completed_ = _initialService(services_);
    }

    function _initialService(address[] calldata services_) internal returns(bool completed_){
        for(uint256 _index = 1; _index <= services_.length; _index++) {
            address activatedAddress = services_[_index - 1];
            if (_index == 1) _services[_index] = address(IGovernanceService(activatedAddress));
            if (_index == 2) _services[_index] = address(ITreasuryService(activatedAddress));
            if (_index == 3) _services[_index] = address(ITokenService(activatedAddress));
        }

        emit InitialService(address(this), _getService(1), _getService(2), _getService(3));
        completed_ = true;
    }

    // TODO: サービスアドレスの取得とその使い方に関してTeamと相談する
    /// @dev サービスのアドレスを取得する
    function getInitialService() external view onlyAdmin returns(address[] memory services_) {
        services_ = new address[](3);
        for(uint256 _index = 1; _index <= 3; _index++) {
            services_[_index - 1] = _services[_index];
        }
    }

    // TODO: サービスアドレスの取得とその使い方に関してTeamと相談する
    /// @dev サービスのアドレスを取得する
    function getService(uint256 index_) external view onlyAdmin returns(address service_) {
        require(index_ <= 0 && _getService(index_) != address(0), "Error: BorderlessComapny/Invalid-Index");

        services_ = _getService(index_);
    }

    function _getService(uint256 index_) internal view returns(address service_) {
        service_ = _services[index_];
    }

    event InitialService(address indexed company_, address governance_, address treasury_, address token_);

    error AlreadyInitialService(address account_);

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Error: BorderlessCompany/Only-Admin");
        _;
    }

    modifier onlyRegister() {
        require(msg.sender == _register, "Error: BorderlessCompany/Only-Register");
        _;
    }
}
