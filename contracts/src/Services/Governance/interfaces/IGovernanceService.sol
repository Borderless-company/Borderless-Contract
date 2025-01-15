// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

/// @title feature interface for GovernanceService contract
interface IGovernanceService {
    // ============================================== //
    //                     Enum                       //
    // ============================================== //

    enum ProposalMember {
        EXECUTIONS_MEMBER,
        MEMBER
    }

    // ============================================== //
    //                   Structs                      //
    // ============================================== //

    struct Transaction {
        uint256 value;
        bytes data;
        address to;
        address executor;
        bool executed;
        bool cancelled;
        uint256 approvalCount;
        uint256 voteStart;
        uint256 voteEnd;
        uint256 createdAt;
        ProposalInfo proposalInfo;
    }

    struct ProposalInfo {
        uint256 numerator;
        uint256 denominator;
        uint8 proposalLevel; // 1: 2/3, 2: 1/2, 3: Custom
        ProposalMember proposalMember;
    }

    // ============================================== //
    //           External Write Functions             //
    // ============================================== //

    /**
     * @dev Approve a transaction
     * @param transactionId_ The transaction ID
     */
    function approveTransaction(uint256 transactionId_) external;

    /**
     * @dev Register a transaction
     * @param value The transaction value
     * @param data The transaction data
     * @param to The transaction to address
     * @param executor The executor address
     * @param proposalLevel The proposal level
     * @param voteStart The vote start time
     * @param voteEnd The vote end time
     */
    function registerTransaction(
        uint256 value,
        bytes memory data,
        address to,
        address executor,
        uint8 proposalLevel,
        uint256 voteStart,
        uint256 voteEnd
    ) external;

    /**
     * @dev Register a transaction with custom threshold
     * @param value The transaction value
     * @param data The transaction data
     * @param to The transaction to address
     * @param executor The executor address
     * @param proposalLevel The proposal level
     * @param numerator The numerator
     * @param denominator The denominator
     * @param voteStart The vote start time
     * @param voteEnd The vote end time
     * @param proposalMember The proposal member
     */
    function registerTransactionWithCustomThreshold(
        uint256 value,
        bytes memory data,
        address to,
        address executor,
        uint8 proposalLevel,
        uint256 numerator,
        uint256 denominator,
        uint256 voteStart,
        uint256 voteEnd,
        ProposalMember proposalMember
    ) external;

    /**
     * @dev Cancel a transaction
     * @param transactionId_ The transaction ID
     */
    function cancelTransaction(
        uint256 transactionId_
    ) external;
}
