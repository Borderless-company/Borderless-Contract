// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {GovernanceBase} from "../GovernanceBase.sol";

// storage
import {Storage as GovernanceStorage} from "../../storages/Storage.sol";

contract Governance_JP_LLC is GovernanceBase {
    function execute(
        uint256 transactionId
    )
        external
        virtual
        override
        onlyExecutor(transactionId)
        thresholdReached(transactionId)
    {
        GovernanceStorage
            .GovernanceSlot()
            .transactions[transactionId]
            .executed = true;
        emit TransactionExecuted(transactionId);
    }
}
