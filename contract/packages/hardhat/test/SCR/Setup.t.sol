// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import { Test } from "forge-std/Test.sol";
import { Common } from "../Common.sol";

import { SCR } from "../../contracts/SCR/SCR.sol";

contract Setup is Test, Common {
    function setUp() public override {
		super.setUp();
	}
}
