// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ILETSBaseEvents} from "./ILETSBaseEvents.sol";
import {ILETSBaseErrors} from "./ILETSBaseErrors.sol";
import {ILETSBaseFunctions} from "./ILETSBaseFunctions.sol";

/**
 * @title feature interface for LETSService contract
 */
interface ILETSBase is ILETSBaseEvents, ILETSBaseErrors, ILETSBaseFunctions {}
