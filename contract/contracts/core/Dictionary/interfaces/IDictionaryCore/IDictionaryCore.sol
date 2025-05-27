// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IDictionaryCoreFunctions} from "./IDictionaryCoreFunctions.sol";
import {IDictionaryCoreEvents} from "./IDictionaryCoreEvents.sol";
import {IDictionaryCoreErrors} from "./IDictionaryCoreErrors.sol";

/**
 * @title IDictionaryCore
 * @notice IDictionaryCore is an interface that defines the core functions of the Dictionary contract.
 */
interface IDictionaryCore is
    IDictionaryCoreFunctions,
    IDictionaryCoreEvents,
    IDictionaryCoreErrors
{}
