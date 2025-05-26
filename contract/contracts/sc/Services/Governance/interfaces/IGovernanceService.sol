// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IGovernanceServiceEvents} from "./IGovernanceServiceEvents.sol";
import {IGovernanceServiceErrors} from "./IGovernanceServiceErrors.sol";
import {IGovernanceServiceFunctions} from "./IGovernanceServiceFunctions.sol";
import {IGovernanceServiceStructs} from "./IGovernanceServiceStructs.sol";

/**
 * @title Feature interface for GovernanceService contract
 * @notice This interface combines all the events, errors, and functions of the GovernanceService contract
 */
interface IGovernanceService is
    IGovernanceServiceEvents,
    IGovernanceServiceErrors,
    IGovernanceServiceFunctions,
    IGovernanceServiceStructs
{}
