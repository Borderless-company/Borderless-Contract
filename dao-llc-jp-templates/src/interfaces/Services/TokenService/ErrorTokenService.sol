// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

interface ErrorTokenService {
    /**
    * @dev パラメータが無効であることを通知するエラーです。
    * @param account アカウントのアドレスです。
    * @param name_ トークンの名前です。
    * @param symbol_ トークンのシンボルです。
    * @param baseURI_ トークンのベースURIです。
    */
    error InvalidParam(address account, string name_, string symbol_, string baseURI_);

    /**
    * @dev パラメータが無効であることを通知するエラーです。
    * @param index_ トークンのインデックス値です。
    */
    error InvalidIndex(uint256 index_);
}
