// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

interface ErrorBorderlessCompany {
  // -- 1. 不正なアドレスパラメータのリバート -- //
  /**
  * @dev アカウントが無効であることを通知するエラーです。
  * @param account_ エラーが発生したアカウントのアドレスです。
  */
  error InvalidAddress(address account_);

  // -- 2. 不正なIndexパラメータのリバート -- //
  /**
  * @dev インデックスが無効であることを通知するエラーです。
  * @param index_ エラーが発生したインデックスです。
  */
  error InvalidIndex(uint256 index_);

  // -- 3. 初期設定済み機能の不正設定リバート -- //
  /**
  * @dev 初期設定済みの機能がすでに設定されていることを通知するエラーです。
  * @param account_ エラーが発生したアカウントのアドレスです。
  */
  error AlreadyInitialService(address account_);

  // -- 4. 既にロール付与していることのリバート -- //
  /**
  * @dev アカウントに既にロールが割り当てられていることを通知するエラーです。
  * @param account_ エラーが発生したアカウントのアドレスです。
  */
  error AlreadyAssignmentRole(address account_);

  // -- 5. 既にロール付与者ではないことのリバート -- //
  /**
  * @dev アカウントが既にロールの解除を受けていることを通知するエラーです。
  * @param account_ エラーが発生したアカウントのアドレスです。
  */
  error AlreadyReleaseRole(address account_);
}
