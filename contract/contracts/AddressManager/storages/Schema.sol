// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ContractType} from "../../utils/ITypes.sol";

/**
 * @title Borderless Address Schema v0.1.0
 */
library Schema {
    struct AddressManagerLayout {
        // contract address mapping
        mapping(ContractType => address) contractAddresses;
        // contract type mapping
        mapping(address => ContractType) contractTypes;
    }
}
