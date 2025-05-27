// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";

import {ProxyUtils} from "./ProxyUtils.sol";
import {IDictionary} from "../Dictionary/interfaces/IDictionary/IDictionary.sol";

/**
 * @title ERC7546: Proxy Contract
 * @notice Proxy contract for the Borderless contract
 */
contract BorderlessProxy is Proxy {
    constructor(address dictionary, bytes memory _data) payable {
        ProxyUtils.upgradeDictionaryToAndCall(dictionary, _data);
        ProxyUtils.setBeacon(dictionary);
    }

    /**
     * @dev Return the implementation address corresponding to the function selector.
     */
    function _implementation() internal view override returns (address) {
        return
            IDictionary(ProxyUtils.getDictionary()).getImplementation(msg.sig);
    }
}
