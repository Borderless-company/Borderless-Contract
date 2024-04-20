// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;
 
interface EventNonFungibleTokenTYPE721 {
    /**
    * @dev トークンセールがアクティブ化されたことを通知するイベントです。
    * @param name_ トークンの名前です。
    * @param symbol_ トークンのシンボルです。
    * @param active_ トークンセールがアクティブであるかどうかを示すブール値です。
    */
    event ActivateTokenSale(string indexed name_, string indexed symbol_, bool active_);

    /**
    * @dev トークンセールが非アクティブ化されたことを通知するイベントです。
    * @param name_ トークンの名前です。
    * @param symbol_ トークンのシンボルです。
    * @param active_ トークンセールがアクティブであるかどうかを示すブール値です。
    */
    event DeactivateTokenSale(string indexed name_, string indexed symbol_, bool active_);

    /**
    * @dev パブリックセールの設定が変更されたことを通知するイベントです。
    * @param saleStart_ セールの開始時刻です。
    * @param saleEnd_ セールの終了時刻です。
    */
    event SetPublicSale(uint256 indexed saleStart_, uint256 indexed saleEnd_);
}
