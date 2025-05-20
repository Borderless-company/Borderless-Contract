// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ISCTEvents} from "./ISCTEvents.sol";
import {ISCTErrors} from "./ISCTErrors.sol";
import {ISCTFunctions} from "./ISCTFunctions.sol";

/**
 * @title ISCT interface v0.1.0
 */
interface ISCT is ISCTEvents, ISCTErrors, ISCTFunctions {}
