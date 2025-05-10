// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {GovernanceBase} from "../GovernanceBase.sol";

contract Governance_JP_LLC is GovernanceBase {
    function initialize(
        address owner,
        address sc,
        bytes memory extraParams
    ) external initializer {
        __GovernanceBase_init(owner, sc, extraParams);
    }
}
