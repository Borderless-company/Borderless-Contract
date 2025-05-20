// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {BorderlessProxy} from "../Proxy/BorderlessProxy.sol";
import {Dictionary} from "../Dictionary/Dictionary.sol";
import {BorderlessAccessControl} from "../BorderlessAccessControl/functions/BorderlessAccessControl.sol";
import {SCInitialize} from "../Initialize/functions/SCInitialize.sol";

// utils
import {ServiceType} from "../utils/ITypes.sol";

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
}
