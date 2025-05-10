// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storages
import {Storage} from "../storages/Storage.sol";

// interfaces
import {IAddressManager} from "../interfaces/IAddressManager.sol";

// utils
import {IErrors} from "../../utils/IErrors.sol";
import {ContractType} from "../../utils/ITypes.sol";

/**
 * @notice contract address management v0.1.0
 */
contract AddressManager is IAddressManager {
    function setContractAddress(
        ContractType contractType,
        address addr
    ) external {
        if (addr == address(0))
            revert IErrors.InvalidContractType(contractType);
        Storage.AddressManagerSlot().contractAddresses[contractType] = addr;
        Storage.AddressManagerSlot().contractTypes[addr] = contractType;
        emit SetContractAddress(contractType, addr);
    }
}
