// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IBeacon} from "@openzeppelin/contracts/proxy/beacon/IBeacon.sol";

/**
 * @title IVerifiable
 * @notice IVerifiable is an interface that defines the functions for a verifiable contract.
 */
interface IVerifiable is IBeacon, IERC165 {
    event FacadeUpgraded(address newFacade);

    /**
     * @notice get implementation address
     * @return implementation address
     */
    function implementation() external view returns (address);

    /**
     * @notice get supported interfaces
     * @return supported interfaces
     */
    function supportsInterfaces() external view returns (bytes4[] memory);
}
