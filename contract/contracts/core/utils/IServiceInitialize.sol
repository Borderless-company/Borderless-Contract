// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title IServiceInitialize
 * @notice IServiceInitialize is an interface that defines the initialize function for the service contracts.
 */
interface IServiceInitialize {
    function initialize(
        address dictionary
    ) external;
}