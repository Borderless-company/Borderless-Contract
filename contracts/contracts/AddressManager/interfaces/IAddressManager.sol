// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IAddressManagerEvents} from "./IAddressManagerEvents.sol";
import {IAddressManagerFunctions} from "./IAddressManagerFunctions.sol";

/**
 * @title address manager interface v0.1.0
 */
interface IAddressManager is IAddressManagerEvents, IAddressManagerFunctions {}