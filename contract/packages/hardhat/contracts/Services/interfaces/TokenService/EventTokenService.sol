// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

interface EventTokenService {
    /**
     * @dev 新しい非代替可能トークン（ERC721）が作成されたことを通知するイベントです。
     * @param token_ 新しい非代替可能トークンのアドレスです。
     * @param symbol_ トークンのシンボルです。
     * @param name_ トークンの名前です。
     * @param sbt_ SBTトークンであるかどうかを示すブール値です。
     */
    event NewNonFungibleToken721(
        address indexed token_,
        string indexed symbol_,
        string indexed name_,
        bool sbt_
    );
}
