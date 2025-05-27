// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// proxy
import {BorderlessAccessControlProxy} from "../../BorderlessAccessControl/proxy/BorderlessAccessControlProxy.sol";
import {DictionaryProxy} from "../../Dictionary/proxy/DictionaryProxy.sol";
import {SCTProxy} from "../../../sc/SCT/proxy/SCTProxy.sol";
import {AOIProxy} from "../../../sc/Services/AOI/proxy/AOIProxy.sol";
import {GovernanceServiceProxy} from "../../../sc/Services/Governance/proxy/GovernanceServiceProxy.sol";

/**
 * @title SCProxy
 * @notice Proxy contract for the SC
 */
contract SCProxy is
    BorderlessAccessControlProxy,
    DictionaryProxy,
    SCTProxy,
    AOIProxy,
    GovernanceServiceProxy
{
    function supportsInterface(
        bytes4 interfaceId
    )
        public
        pure
        override(BorderlessAccessControlProxy, DictionaryProxy)
        returns (bool)
    {}
}
