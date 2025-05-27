// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// libs
import {DictionaryCoreLib} from "../libs/DictionaryCoreLib.sol";

// interfaces
import {IDictionaryCore} from "../interfaces/IDictionaryCore/IDictionaryCore.sol";
import {IDictionaryCoreFunctions} from "../interfaces/IDictionaryCore/IDictionaryCoreFunctions.sol";
import {IVerifiable} from "../interfaces/IVerifiable.sol";

// OpenZeppelin
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title DictionaryCore
 * @notice DictionaryCore is a base contract for the Dictionary contract.
 */
abstract contract DictionaryCore is IDictionaryCore, IVerifiable {
    // ============================================== //
    //              EXTERNAL READ FUNCTIONS           //
    // ============================================== //

    function getImplementation(
        bytes4 selector
    ) external view virtual override returns (address) {
        return DictionaryCoreLib.getImplementation(selector);
    }

    function implementation()
        external
        view
        virtual
        override(IDictionaryCoreFunctions, IVerifiable)
        returns (address)
    {
        return DictionaryCoreLib.implementation();
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        external
        view
        virtual
        override(IDictionaryCoreFunctions, IERC165)
        returns (bool)
    {
        return DictionaryCoreLib.supportsInterface(interfaceId);
    }

    function supportsInterfaces()
        external
        view
        virtual
        override(IDictionaryCoreFunctions, IVerifiable)
        returns (bytes4[] memory)
    {
        return DictionaryCoreLib.supportsInterfaces();
    }
}
