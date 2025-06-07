// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// proxy
import {BorderlessAccessControlFacade} from "../../BorderlessAccessControl/facades/BorderlessAccessControlFacade.sol";
import {DictionaryFacade} from "../../Dictionary/facades/DictionaryFacade.sol";
import {SCTFacade} from "../../../sc/SCT/facades/SCTFacade.sol";
import {AOIFacade} from "../../../sc/Services/AOI/facades/AOIFacade.sol";
import {GovernanceServiceFacade} from "../../../sc/Services/Governance/facades/GovernanceServiceFacade.sol";

/**
 * @title SCFacade
 * @notice Proxy contract for the SC
 */
contract SCFacade is
    BorderlessAccessControlFacade,
    DictionaryFacade,
    SCTFacade,
    AOIFacade,
    GovernanceServiceFacade
{
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        pure
        override(BorderlessAccessControlFacade, DictionaryFacade)
        returns (bool)
    {}
}
