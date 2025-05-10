// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ContractType} from "../../utils/ITypes.sol";

/**
 * @title address manager interface v0.1.0
 */
interface IAddressManagerFunctions {
    /**
     * @notice set contract address
     * @param contractType contract type
     * @param addr contract address
     */
    function setContractAddress(ContractType contractType, address addr) external;
}
