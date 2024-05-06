// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

/// @title feature interface for TokenService contract
interface ITokenService {
    struct TokenInfo {
        address token_;
        string name_;
        string symbol_;
        uint256 createAt;
        bool sbt_;
    }

    /**
    * @dev ERC721標準のトークンをアクティブ化するための関数です。
    * @param name_ トークンの名前です。
    * @param symbol_ トークンのシンボルです。
    * @param baseURI_ トークンのベースURIです。
    * @param sbt_ SBTトークンであるかどうかを示すブール値です。
    * @return success_ 新しいERC721トークン生成の成功を示すブール値です。
    */
    function activateStandard721Token(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        bool sbt_
    ) external returns(bool success_);

    /**
    * @dev ERC721標準のトークンの最後のインデックスを取得するための関数です。
    * @return index_ ERC721標準のトークンの最後のインデックスです。
    */
    function getLastIndexStandard721Token() external view returns(uint256 index_);

    /**
    * @dev 指定されたインデックスのERC721標準のトークンに関する情報を取得するための関数です。
    * @param index_ 取得したいERC721標準のトークンのインデックスです。
    * @return token_ ERC721標準のトークンのアドレスです。
    * @return name_ ERC721標準のトークンの名前です。
    * @return symbol_ ERC721標準のトークンのシンボルです。
    * @return sbt_ SBTであるかを示すブール値です。
    */
    function getInfoStandard721token(uint256 index_) external view returns(address token_, string memory name_, string memory symbol_, bool sbt_);
}
