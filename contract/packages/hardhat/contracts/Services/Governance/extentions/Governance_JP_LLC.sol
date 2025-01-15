// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {GovernanceBase} from "../GovernanceBase.sol";

contract Governance_JP_LLC is GovernanceBase {
    function initialize(
        address _owner,
        address sc_,
        bytes memory _extraParams
    ) external initializer {
        __GovernanceBase_init(_owner, sc_, _extraParams);
    }
}
