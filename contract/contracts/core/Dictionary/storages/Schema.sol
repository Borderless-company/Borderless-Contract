// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title AccessControlUpgradeable Schema v0.1.0
 */
library Schema {
    struct DictionaryBaseLayout {
        mapping(bytes4 selector => address implementation) functions;
        bytes4[] functionSelectorList;
        address facade;
    }

    struct DictionaryLayout {
        mapping(address account => mapping(address implementation => bool isInitialized)) onceInitialized;
    }
}
