// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {BorderlessAccessControlProxy} from "../../BorderlessAccessControl/proxy/BorderlessAccessControlProxy.sol";
import {DictionaryProxy} from "../../Dictionary/proxy/DictionaryProxy.sol";
import {OwnableProxy} from "../../Ownable/proxy/OwnableProxy.sol";
import {SCRBeaconUpgradeableProxy} from "../../../scr/BeaconUpgradeableBase/proxy/SCRBeaconUpgradeableProxy.sol";
import {ServiceFactoryBeaconUpgradeableProxy} from "../../../scr/BeaconUpgradeableBase/proxy/ServiceFactoryBeaconUpgradeableProxy.sol";
import {ServiceFactoryProxy} from "../../../scr/Factory/proxy/ServiceFactoryProxy.sol";
import {CompanyInfoProxy} from "../../../scr/SCR/proxy/CompanyInfoProxy.sol";
import {ISCRProxy} from "../../../scr/SCR/proxy/ISCRProxy.sol";

/**
 * @title SCRProxy
 * @notice SCRProxy is a proxy contract for the SCR contract.
 */
contract SCRProxy is
    BorderlessAccessControlProxy,
    DictionaryProxy,
    OwnableProxy,
    SCRBeaconUpgradeableProxy,
    ServiceFactoryBeaconUpgradeableProxy,
    ServiceFactoryProxy,
    CompanyInfoProxy,
    ISCRProxy
{
    // ============================================== //
    //                  OVERRIDE                      //
    // ============================================== //

    function supportsInterface(
        bytes4 interfaceId
    )
        external
        view
        override(BorderlessAccessControlProxy, DictionaryProxy)
        returns (bool)
    {}
}
