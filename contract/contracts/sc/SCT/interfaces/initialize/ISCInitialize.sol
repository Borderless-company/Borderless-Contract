// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ISCInitialize {
    /**
     * @dev Initialize the SCT
     * @param dictionary The dictionary address
     * @param implementation The implementation address
     * @param founder The founder address
     * @param scr The SCR address
     */
    function initialize(
        address dictionary,
        address implementation,
        address founder,
        address scr
    ) external;
}
