// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {SCT} from "../SCT.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {console} from "hardhat/console.sol";

/// @title Smart Company for Japan DAO LLC
contract SC_JP_DAOLLC is Initializable, SCT {
    function initialize(
        address founder,
        address scr,
        bytes calldata
    ) external initializer {
        console.log("call initialize");
        __SCT_initialize(founder, scr);
    }
}
