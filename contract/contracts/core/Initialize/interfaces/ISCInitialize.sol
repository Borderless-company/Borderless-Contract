// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ISCInitialize {
    function initialize(address founder, address scr) external;
}

interface ISCTInitialize {
    function initialize(address sc, address dictionary) external;
}
