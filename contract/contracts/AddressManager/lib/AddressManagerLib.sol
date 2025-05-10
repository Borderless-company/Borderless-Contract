// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Schema} from "../storages/Schema.sol";

// utils
import {IErrors} from "../../utils/IErrors.sol";
import {ContractType} from "../../utils/ITypes.sol";

/**
 * @title AddressManager
 * @notice This library is used to manage the addresses of the contracts.
 */
library AddressManagerLib {
    function onlySCR(
        Schema.AddressManagerLayout storage slot,
        address account
    ) internal view {
        require(
            slot.contractAddresses[ContractType.SCR] == account,
            IErrors.NotSCR(account)
        );
    }

    function getContractAddress(
        Schema.AddressManagerLayout storage slot,
        ContractType contractType
    ) internal view returns (address) {
        return slot.contractAddresses[contractType];
    }

    function getContentType(
        Schema.AddressManagerLayout storage slot,
        address addr
    ) internal view returns (ContractType) {
        return slot.contractTypes[addr];
    }
}
