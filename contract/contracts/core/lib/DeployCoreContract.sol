// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {BorderlessProxy} from "../Proxy/BorderlessProxy.sol";
import {Dictionary} from "../Dictionary/functions/Dictionary.sol";
import {BorderlessAccessControl} from "../BorderlessAccessControl/functions/BorderlessAccessControl.sol";
import {SCInitialize} from "../../sc/SCT/functions/initialize/SCInitialize.sol";
import {Ownable} from "../Ownable/functions/Ownable.sol";
// utils
import {ServiceType} from "../utils/ITypes.sol";

/**
 * @title DeployCoreContract
 * @notice DeployCoreContract is a library that deploys the core contracts.
 */
library DeployCoreContract {
    function deployProxy(
        address dictionary,
        bytes memory _data
    ) internal returns (address) {
        return address(new BorderlessProxy(dictionary, _data));
    }

    function deployDictionary(address founder) internal returns (address) {
        return address(new Dictionary(founder));
    }

    function deployBorderlessAccessControl() internal returns (address) {
        return address(new BorderlessAccessControl());
    }

    function deploySCInitialize() internal returns (address) {
        return address(new SCInitialize());
    }

    function deployOwnable() internal returns (address) {
        return address(new Ownable());
    }
}
