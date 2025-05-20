// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IAOIErrors} from "./IAOIErrors.sol";
import {IAOIEvents} from "./IAOIEvents.sol";
import {IAOIStructs} from "./IAOIStructs.sol";
import {IAOIFunctions} from "./IAOIFunctions.sol";

interface IAOI is IAOIErrors, IAOIEvents, IAOIStructs, IAOIFunctions {}
