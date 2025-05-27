// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IDictionaryCore} from "../IDictionaryCore/IDictionaryCore.sol";
import {IDictionaryFunctions} from "./IDictionaryFunctions.sol";
import {IDictionaryErrors} from "./IDictionaryErrors.sol";

/**
 * @title IDictionary
 * @notice IDictionary is an interface that defines the functions for a dictionary contract.
 */
interface IDictionary is
    IDictionaryCore,
    IDictionaryFunctions,
    IDictionaryErrors
{}
