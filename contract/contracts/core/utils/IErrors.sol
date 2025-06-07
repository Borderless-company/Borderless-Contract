// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ContractType} from "./ITypes.sol";

/**
 * @title IErrors
 * @notice IErrors is an interface that defines the errors for the core contracts.
 */
interface IErrors {
    error NotFounder(address sender);
    error NotTreasuryRole(address sender);

    error EmptyString(string str);
    error InvalidParam(bytes32 param);
    error InvalidLength(uint256 length, uint256 expected);

    // token
    error NotTokenHolder(address sender);
}
