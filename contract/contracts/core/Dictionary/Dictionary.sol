// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {DictionaryBase} from "./base/DictionaryBase.sol";
import {IDictionary} from "./interfaces/IDictionary.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
    @title ERC7546: Standard Dictionary Contract
 */
contract Dictionary is DictionaryBase, Ownable, IDictionary {
    mapping(address account => mapping(address implementation => bool isInitialized))
        internal onceInitialized;
    // ============================================== //
    //                  Modifier                      //
    // ============================================== //

    modifier onlyOwnerOrOnceInitialized(address implementation) {
        address account = msg.sender;
        require(
            account == owner() ||
                onceInitialized[account][implementation],
            NotOwnerOrInitialized(account, implementation)
        );
        _;
        if (!onceInitialized[account][implementation]) {
            onceInitialized[account][implementation] = false;
        }
    }

    // ============================================== //
    //                  Constructor                   //
    // ============================================== //

    constructor(address owner) Ownable(owner) {
    }

    // ============================================== //
    //              External Write Functions          //
    // ============================================== //

    function setImplementation(
        bytes4 selector,
        address implementation
    ) external override onlyOwnerOrOnceInitialized(implementation) {
        _setImplementation(selector, implementation);
    }

    function bulkSetImplementation(
        bytes4[] memory selectors,
        address implementation
    ) external override {
        for (uint256 i = 0; i < selectors.length; i++) {
            _setImplementation(selectors[i], implementation);
        }
    }

    function bulkSetImplementation(
        bytes4[] memory selectors,
        address[] memory implementations
    ) external override {
        for (uint256 i = 0; i < selectors.length; i++) {
            _setImplementation(selectors[i], implementations[i]);
        }
    }

    function upgradeFacade(address newFacade) external override onlyOwner {
        _upgradeFacade(newFacade);
    }

    function setOnceInitialized(
        address account,
        address implementation
    ) external override onlyOwner {
        onceInitialized[account][implementation] = true;
    }

    // ============================================== //
    //              External Read Functions           //
    // ============================================== //

    function getFacade() external view override returns (address) {
        return facade;
    }
}
