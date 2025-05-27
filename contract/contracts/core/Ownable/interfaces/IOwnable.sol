// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IOwnableErrors} from "./IOwnableErrors.sol";
import {IOwnableEvents} from "./IOwnableEvents.sol";
import {IOwnableFunctions} from "./IOwnableFunctions.sol";

interface IOwnable is IOwnableErrors, IOwnableEvents, IOwnableFunctions {}
