// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {BorderlessAccessControlFacade} from "../../BorderlessAccessControl/facades/BorderlessAccessControlFacade.sol";
import {DictionaryFacade} from "../../Dictionary/facades/DictionaryFacade.sol";
import {OwnableFacade} from "../../Ownable/facades/OwnableFacade.sol";
import {SCRBeaconUpgradeableFacade} from "../../../scr/BeaconUpgradeableBase/facades/SCRBeaconUpgradeableFacade.sol";
import {ServiceFactoryBeaconUpgradeableFacade} from "../../../scr/BeaconUpgradeableBase/facades/ServiceFactoryBeaconUpgradeableFacade.sol";
import {ServiceFactoryFacade} from "../../../scr/Factory/facades/ServiceFactoryFacade.sol";
import {CompanyInfoFacade} from "../../../scr/SCR/facades/CompanyInfoFacade.sol";
import {SCRFacade} from "../../../scr/SCR/facades/SCRFacade.sol";

/**
 * @title BorderlessProxyFacade
 * @notice BorderlessProxyFacade is a proxy contract for the SCR contract.
 */
contract BorderlessProxyFacade is
    BorderlessAccessControlFacade,
    DictionaryFacade,
    OwnableFacade,
    SCRBeaconUpgradeableFacade,
    ServiceFactoryBeaconUpgradeableFacade,
    ServiceFactoryFacade,
    CompanyInfoFacade,
    SCRFacade
{
    // ============================================== //
    //                  OVERRIDE                      //
    // ============================================== //

    function supportsInterface(
        bytes4 interfaceId
    )
        external
        view
        override(BorderlessAccessControlFacade, DictionaryFacade)
        returns (bool)
    {}
}
