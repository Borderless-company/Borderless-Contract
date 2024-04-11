// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

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
