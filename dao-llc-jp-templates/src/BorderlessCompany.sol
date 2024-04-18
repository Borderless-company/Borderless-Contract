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
    IGovernanceService private _governanceService;
    ITreasuryService private _treasuryService;
    ITokenService private _tokenService;

    // TODO: Whitelistコントラクトを用いたアドレスのホワイトリスト制御を実装する
    constructor(address admin_, address register_) {
        _admin = admin_;
        _register = register_;
    }

    function initialService(address[] calldata services_) external override onlyRegister returns(bool completed_){
        for(uint256 _index = 1; _index <= services_.length; _index++) {
            address activatedAddress = services_[_index - 1];
            if (_index == 1) _governanceService = IGovernanceService(activatedAddress);
            if (_index == 2) _treasuryService = ITreasuryService(activatedAddress);
            if (_index == 3) _tokenService = ITokenService(activatedAddress);
        }

        emit InitialService(msg.sender, address(_governanceService), address(_treasuryService), address(_tokenService));
        completed_ = true;
    }

    // TODO: 削除する機能（テスト用feature）
    function callAdmin() external view override onlyAdmin() returns(bool) {
        return true;
    }

    event InitialService(address indexed company_, address governance_, address treasury_, address token_);

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Error: BorderlessCompany/Only-Admin");
        _;
    }

    modifier onlyRegister() {
        require(msg.sender == _register, "Error: BorderlessCompany/Only-Register");
        _;
    }
}
