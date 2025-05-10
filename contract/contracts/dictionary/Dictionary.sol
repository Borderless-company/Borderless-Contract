// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {DictionaryBase} from "./base/DictionaryBase.sol";
import {IDictionary} from "./interfaces/IDictionary.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";


/**
    @title ERC7546: Standard Dictionary Contract
 */
contract Dictionary is DictionaryBase, Ownable, IDictionary {
    constructor(address owner) Ownable(owner) {}

    function setImplementation(bytes4 selector, address implementation) external onlyOwner {
        _setImplementation(selector, implementation);
    }

    function upgradeFacade(address newFacade) external onlyOwner {
        _upgradeFacade(newFacade);
    }

    function getFacade() external view returns (address) {
        return facade;
    }

    function getImplementation(bytes4 selector) external view override(DictionaryBase, IDictionary) returns(address) {
        return _getImplementation(selector);
    }

    function supportsInterface(bytes4 interfaceId) external view override(DictionaryBase, IDictionary) returns(bool) {
        return _supportsInterface(interfaceId);
    }
}