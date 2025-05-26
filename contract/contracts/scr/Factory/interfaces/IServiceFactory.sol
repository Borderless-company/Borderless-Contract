// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IServiceFactoryFunctions} from "./IServiceFactoryFunctions.sol";
import {IServiceFactoryErrors} from "./IServiceFactoryErrors.sol";
import {IServiceFactoryEvents} from "./IServiceFactoryEvents.sol";

/**
 * @dev Interface for the Service Factory v0.1.0
 */
interface IServiceFactory is
    IServiceFactoryFunctions,
    IServiceFactoryErrors,
    IServiceFactoryEvents
{}
