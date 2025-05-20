// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {DictionaryBase} from "./base/DictionaryBase.sol";
import {IDictionary} from "./interfaces/IDictionary.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {console} from "hardhat/console.sol";

/**
    @title ERC7546: Standard Dictionary Contract
 */
contract Dictionary is DictionaryBase, Ownable, IDictionary {
    mapping(address account => mapping(address implementation => bool isInitialized))
        internal onceInitialized;
    // ============================================== //
    //                  Modifier                      //
    // ============================================== //

    modifier checkLength(
        bytes4[] memory selectors,
        address[] memory implementations
    ) {
        require(
            selectors.length == implementations.length &&
                selectors.length > 0 &&
                implementations.length <= 100,
            InvalidBulkLength(selectors.length, implementations.length)
        );
        _;
    }

    modifier onlyOwnerOrOnceInitialized(address implementation) {
        address account = msg.sender;
        console.log("msg.sender", account);
        console.log("implementation", implementation);
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
        console.log("Dictionary constructor");
        console.log("owner", owner);
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
        address[] memory implementations
    ) external override checkLength(selectors, implementations) {
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
