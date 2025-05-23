// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IPriceManagerFunctions} from "./IPriceManagerFunctions.sol";
import {IPriceManagerEvents} from "./IPriceManagerEvents.sol";
import {IPriceManagerErrors} from "./IPriceManagerErrors.sol";

interface IPriceManager is
    IPriceManagerFunctions,
    IPriceManagerEvents,
    IPriceManagerErrors
{}
