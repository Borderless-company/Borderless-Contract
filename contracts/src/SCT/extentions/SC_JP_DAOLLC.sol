// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import { SCT } from "../SCT.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title Smart Company for Japan DAO LLC
contract SC_JP_DAOLLC is Initializable, SCT {
	function initialize(
		address _admin,
		address _register,
		bytes calldata
	) external initializer {
		__SCT_initialize(_admin, _register);
	}
}
