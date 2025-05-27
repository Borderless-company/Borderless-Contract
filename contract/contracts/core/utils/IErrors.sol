// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ContractType} from "./ITypes.sol";

/**
 * @title IErrors
 * @notice IErrors is an interface that defines the errors for the core contracts.
 */
interface IErrors {
    error NotSCR(address sender);
    error NotFounder(address sender);
    error NotTreasuryRole(address sender);
    error InitialMintExecuteMemberCompleted();

    error ZeroAddress();
    error EmptyString(string str);
    error InvalidParam(bytes32 param);
    error InvalidLength(uint256 length, uint256 expected);

    error SCNotOnline(address serviceImplementation);

    // role
    error InvalidFounderRole(address founder);
    error InvalidTreasuryRole(address treasury);

    // token
    error NotTokenHolder(address sender);

    error InvalidContractType(ContractType contractType);

}
