// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ContractType} from "../../utils/ITypes.sol";

/**
 * @title address manager interface v0.1.0
 */
interface IAddressManagerEvents {
    event SetContractAddress(ContractType contractType, address addr);
}
