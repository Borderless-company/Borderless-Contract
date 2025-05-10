// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IServiceInitialize {
    function initialize(
        address admin,
        address serviceFactory,
        bytes memory extraParams
    ) external;
}

interface ILETSSaleInitialize {
    function initialize(
        address scr
    ) external;
}
