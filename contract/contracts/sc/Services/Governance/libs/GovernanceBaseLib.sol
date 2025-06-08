// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage as GovernanceStorage} from "../storages/Storage.sol";

// lib
import {GovernanceBaseLib} from "../libs/GovernanceBaseLib.sol";

// interfaces
import {IGovernanceServiceStructs} from "../interfaces/IGovernanceServiceStructs.sol";
import {IGovernanceServiceEvents} from "../interfaces/IGovernanceServiceEvents.sol";
import {IGovernanceServiceErrors} from "../interfaces/IGovernanceServiceErrors.sol";

// OpenZeppelin
import {IERC721} from "../../../ERC721/interfaces/IERC721.sol";

/**
 * @title GovernanceBaseLib
 * @notice This library contains the functions for the GovernanceBase contract
 */
library GovernanceBaseLib {
    // ============================================== //
    //                 WRITE FUNCTIONS                //
    // ============================================== //

    /**
     * @dev Execute a transaction
     * @param transactionId Transaction ID
     */
    function execute(uint256 transactionId) internal {
        IGovernanceServiceStructs.Transaction storage transaction = GovernanceStorage
            .GovernanceSlot()
            .transactions[transactionId];
        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        transaction.executed = true;
        require(success, IGovernanceServiceErrors.ExecuteFailed(transactionId));
        emit IGovernanceServiceEvents.TransactionExecuted(transactionId);
    }

    /**
     * @dev Approve a transaction
     * @param transactionId Transaction ID
     */
    function approveTransaction(uint256 transactionId) internal {
        GovernanceStorage.GovernanceSlot().approvals[transactionId][
            msg.sender
        ] = true;
        GovernanceStorage
            .GovernanceSlot()
            .transactions[transactionId]
            .approvalCount++;
        emit IGovernanceServiceEvents.TransactionApproved(transactionId, msg.sender);
    }

    /**
     * @dev Register a new transaction
     * @param value Transaction value
     * @param data Transaction data
     * @param to Transaction to address
     * @param executor Transaction executor address
     * @param proposalLevel Proposal level
     * @param voteStart Vote start time
     * @param voteEnd Vote end time
     * @param proposalMemberContracts Proposal member contracts
     */
    function registerTransaction(
        uint256 value,
        bytes memory data,
        address to,
        address executor,
        IGovernanceServiceStructs.ProposalLevel proposalLevel,
        uint256 voteStart,
        uint256 voteEnd,
        address[] memory proposalMemberContracts
    ) internal {
        IGovernanceServiceStructs.ProposalInfo memory proposalInfo = IGovernanceServiceStructs.ProposalInfo({
            numerator: proposalLevel == IGovernanceServiceStructs.ProposalLevel.LEVEL_1 ? 2 : 1, // 2/3 or 1/2
            denominator: proposalLevel == IGovernanceServiceStructs.ProposalLevel.LEVEL_1 ? 3 : 2, // 2/3 or 1/2
            proposalLevel: proposalLevel,
            proposalMemberContracts: proposalMemberContracts
        });
        _registerTransaction(
            value,
            data,
            to,
            executor,
            voteStart,
            voteEnd,
            proposalInfo
        );
    }

    function registerTransactionWithCustomThreshold(
        uint256 value,
        bytes memory data,
        address to,
        address executor,
        IGovernanceServiceStructs.ProposalLevel proposalLevel,
        uint256 numerator,
        uint256 denominator,
        uint256 voteStart,
        uint256 voteEnd,
        address[] memory proposalMemberContracts
    ) internal {
        require(
            numerator > 0 && denominator > 0,
            IGovernanceServiceErrors.InvalidNumeratorOrDenominator(numerator, denominator)
        );
        IGovernanceServiceStructs.ProposalInfo memory proposalInfo = IGovernanceServiceStructs.ProposalInfo({
            numerator: numerator,
            denominator: denominator,
            proposalLevel: proposalLevel,
            proposalMemberContracts: proposalMemberContracts
        });
        _registerTransaction(
            value,
            data,
            to,
            executor,
            voteStart,
            voteEnd,
            proposalInfo
        );
    }

    function cancelTransaction(uint256 transactionId_) internal {
        GovernanceStorage
            .GovernanceSlot()
            .transactions[transactionId_]
            .cancelled = true;
        emit IGovernanceServiceEvents.TransactionCancelled(transactionId_);
    }

    // ============================================== //
    //                 READ FUNCTIONS                 //
    // ============================================== //

    /**
     * @dev Get the last transaction ID
     * @return Last transaction ID
     */
    function getLastTransactionId() internal view returns (uint256) {
        return GovernanceStorage.GovernanceSlot().lastTransactionId;
    }

    /**
     * @dev Get a transaction
     * @param transactionId Transaction ID
     * @return Transaction
     */
    function getTransaction(
        uint256 transactionId
    ) internal view returns (IGovernanceServiceStructs.Transaction memory) {
        return GovernanceStorage.GovernanceSlot().transactions[transactionId];
    }

    /**
     * @dev Get an approval
     * @param transactionId Transaction ID
     * @param account Account address
     * @return Approval
     */
    function getApproval(
        uint256 transactionId,
        address account
    ) internal view returns (bool) {
        return GovernanceStorage.GovernanceSlot().approvals[transactionId][
            account
        ];
    }

    // ============================================== //
    //             INTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    function _registerTransaction(
        uint256 value,
        bytes memory data,
        address to,
        address executor,
        uint256 voteStart,
        uint256 voteEnd,
        IGovernanceServiceStructs.ProposalInfo memory proposalInfo
    ) internal {
        uint256 transactionId = ++GovernanceStorage
            .GovernanceSlot()
            .lastTransactionId;
        uint256 totalMember;
        for (uint256 i = 0; i < proposalInfo.proposalMemberContracts.length; i++) {
            totalMember += IERC721(proposalInfo.proposalMemberContracts[i]).totalSupply();
        }
        GovernanceStorage.GovernanceSlot().transactions[
            transactionId
        ] = IGovernanceServiceStructs.Transaction({
            value: value,
            data: data,
            to: to,
            executor: executor,
            executed: false,
            cancelled: false,
            totalMember: totalMember,
            approvalCount: 0,
            voteStart: voteStart,
            voteEnd: voteEnd,
            createdAt: block.timestamp,
            proposalInfo: proposalInfo
        });
        emit IGovernanceServiceEvents.TransactionCreated(transactionId);
    }
}
