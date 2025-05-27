// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {DictionaryCore} from "./DictionaryCore.sol";
import {Ownable} from "../../Ownable/functions/Ownable.sol";

// storage
import {Schema as DictionarySchema} from "../storages/Schema.sol";
import {Storage as DictionaryStorage} from "../storages/Storage.sol";

// libs
import {DictionaryLib} from "../libs/DictionaryLib.sol";
import {DictionaryCoreLib} from "../libs/DictionaryCoreLib.sol";

// interfaces
import {IDictionary} from "../interfaces/IDictionary/IDictionary.sol";
import {IVerifiable} from "../interfaces/IVerifiable.sol";
import {IDictionaryCoreFunctions} from "../interfaces/IDictionaryCore/IDictionaryCoreFunctions.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IDictionaryFunctions} from "../interfaces/IDictionary/IDictionaryFunctions.sol";

/**
    @title ERC7546: Standard Dictionary Contract
 */
contract Dictionary is DictionaryCore, Ownable, IDictionary {
    // ============================================== //
    //                  MODIFIER                      //
    // ============================================== //

    modifier onlyOwnerOrOnceInitialized(address implementation_) {
        address account = msg.sender;
        DictionarySchema.DictionaryLayout storage $ = DictionaryStorage
            .DictionarySlot();
        require(
            account == owner() || $.onceInitialized[account][implementation_],
            NotOwnerOrInitialized(account, implementation_)
        );
        _;
        if (!$.onceInitialized[account][implementation_]) {
            $.onceInitialized[account][implementation_] = false;
        }
    }

    // // ============================================== //
    // //                  INITIALIZE                    //
    // // ============================================== //

    // function initialize(
    //     address owner_
    // ) public virtual override {
    //     initialize(owner_);
    // }

    // ============================================== //
    //                  CONSTRUCTOR                   //
    // ============================================== //

    constructor(address owner_) {
        initialize(owner_);
    }

    // ============================================== //
    //              EXTERNAL WRITE FUNCTIONS          //
    // ============================================== //

    function setImplementation(
        bytes4 selector,
        address implementation_
    ) external override onlyOwnerOrOnceInitialized(implementation_) {
        DictionaryLib.setImplementation(selector, implementation_);
    }

    function bulkSetImplementation(
        bytes4[] memory selectors,
        address implementation_
    ) external override {
        DictionaryLib.bulkSetImplementation(selectors, implementation_);
    }

    function bulkSetImplementation(
        bytes4[] memory selectors,
        address[] memory implementations
    ) external override {
        DictionaryLib.bulkSetImplementation(selectors, implementations);
    }

    function upgradeFacade(address newFacade) external override onlyOwner {
        DictionaryLib.upgradeFacade(newFacade);
    }

    function setOnceInitialized(
        address account,
        address implementation_
    ) external override onlyOwner {
        DictionaryLib.setOnceInitialized(account, implementation_);
    }

    // ============================================== //
    //              EXTERNAL READ FUNCTIONS           //
    // ============================================== //

    function getFacade() external view override returns (address) {
        return DictionaryLib.getFacade();
    }

    function implementation()
        external
        view
        override(DictionaryCore, IDictionaryCoreFunctions)
        returns (address)
    {
        return DictionaryCoreLib.implementation();
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        external
        view
        override(DictionaryCore, IDictionaryCoreFunctions)
        returns (bool)
    {
        return DictionaryCoreLib.supportsInterface(interfaceId);
    }

    function supportsInterfaces()
        external
        view
        override(DictionaryCore, IDictionaryCoreFunctions)
        returns (bytes4[] memory)
    {
        return DictionaryCoreLib.supportsInterfaces();
    }
}
