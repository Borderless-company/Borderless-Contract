// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ILETSSaleBaseEvents} from "./ILETSSaleBaseEvents.sol";
import {ILETSSaleBaseErrors} from "./ILETSSaleBaseErrors.sol";
import {ILETSSaleBaseFunctions} from "./ILETSSaleBaseFunctions.sol";

/**
 * @title feature interface for Legal Embedded Token Service Sale contract
 */
interface ILETSSaleBase is
    ILETSSaleBaseEvents,
    ILETSSaleBaseErrors,
    ILETSSaleBaseFunctions
{}
