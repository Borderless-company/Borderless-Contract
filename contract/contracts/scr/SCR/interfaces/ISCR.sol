// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ISCRFunctions} from "./ISCRFunctions.sol";
import {ISCRErrors} from "./ISCRErrors.sol";
import {ISCREvents} from "./ISCREvents.sol";

/**
 * @dev Interface for the SmartCompany Registry v0.1.0
 */
interface ISCR is ISCRFunctions, ISCRErrors, ISCREvents {}
