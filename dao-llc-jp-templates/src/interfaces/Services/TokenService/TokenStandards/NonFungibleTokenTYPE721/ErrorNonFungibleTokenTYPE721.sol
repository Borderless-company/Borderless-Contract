// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;
 
interface ErrorNonFungibleTokenTYPE721 {
    /**
    * @dev アカウントがトークンを発行済みであることを通知するエラーです。
    * @param account_ エラーが発生したアカウントのアドレスです。
    * @param name_ エラーの詳細です。
    * @param symbol_ エラーの詳細です。
    */
    error AlreadyMinted(address account_, string name_, string symbol_);

    /**
    * @dev アカウントがトークンを発行に失敗したことを通知するエラーです。
    * @param account_ エラーが発生したアカウントのアドレスです。
    * @param name_ エラーの詳細です。
    * @param symbol_ エラーの詳細です。
    */
    error DoNotMint(address account_, string name_, string symbol_);

    /**
    * @dev トークンがロックされていることを通知するエラーです。
    * @param locked_ トークンがロックされているかどうかを示すブール値です。
    */
    error TokenLocked(bool locked_);

    /**
    * @dev すでにトークンセールがアクティブ化されていることを通知するエラーです。
    * @param active_ トークンセールがアクティブであるかどうかを示すブール値です。
    */
    error AlreadySaleActivate(bool active_);

    /**
    * @dev すでにトークンセールが非アクティブ化されていることを通知するエラーです。
    * @param active_ トークンセールがアクティブであるかどうかを示すブール値です。
    */
    error AlreadySaleDeactivate(bool active_);

    /**
    * @dev 指定された時刻が無効であることを通知するエラーです。
    * @param saleStart_ セールの開始時刻です。
    * @param saleEnd_ セールの終了時刻です。
    */
    error InvalidTime(uint256 saleStart_, uint256 saleEnd_);
}