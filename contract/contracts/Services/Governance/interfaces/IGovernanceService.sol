// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @title feature interface for GovernanceService contract
interface IGovernanceService {
    // ============================================== //
    //                     Events                     //
    // ============================================== //

    /**
     * @dev Event when a transaction is created
     * @param transactionId The transaction ID
     */
    event TransactionCreated(uint256 transactionId);

    /**
     * @dev Event when a transaction is executed
     * @param transactionId The transaction ID
     */
    event TransactionExecuted(uint256 transactionId);

    /**
     * @dev Event when a transaction is approved
     * @param transactionId The transaction ID
     * @param executor The executor address
     */
    event TransactionApproved(uint256 transactionId, address executor);

    /**
     * @dev Event when a transaction is cancelled
     * @param transactionId The transaction ID
     */
    event TransactionCancelled(uint256 transactionId);

    // ============================================== //
    //                     Errors                     //
    // ============================================== //

    /**
     * @dev Error when the transaction execution fails
     * @param transactionId The transaction ID
     */
    error ExecuteFailed(uint256 transactionId);

    /**
     * @dev Error when the executor is not an execution member
     * @param executor The executor address
     */
    error NotExecutionMember(address executor);

    /**
     * @dev Error when the executor is not the executor of the transaction
     * @param executor The executor address
     * @param transactionId The transaction ID
     */
    error NotExecutor(address executor, uint256 transactionId);

    /**
     * @dev Error when the transaction is already approved
     * @param executor The executor address
     * @param transactionId The transaction ID
     */
    error AlreadyApproved(address executor, uint256 transactionId);

    /**
     * @dev Error when the executor is not an SC or LETS
     * @param executor The executor address
     */
    error NotSCorLETS(address executor);

    /**
     * @dev Error when the caller is not the governance contract
     * @param caller The caller address
     */
    error NotGovernanceContract(address caller);

    /**
     * @dev Error when the transaction is not in the vote period
     * @param transactionId The transaction ID
     */
    error NotInVotePeriod(uint256 transactionId);

    /**
     * @dev Error when the threshold is not reached
     * @param transactionId The transaction ID
     */
    error ThresholdNotReached(uint256 transactionId);

    /**
     * @dev Error when the proposal level is invalid
     * @param proposalLevel The proposal level
     */
    error InvalidProposalLevel(ProposalLevel proposalLevel);

    /**
     * @dev Error when the numerator or denominator is invalid
     * @param numerator The numerator
     * @param denominator The denominator
     */
    error InvalidNumeratorOrDenominator(uint256 numerator, uint256 denominator);

    // ============================================== //
    //                     Enum                       //
    // ============================================== //

    enum ProposalLevel {
        LEVEL_1, // 2/3
        LEVEL_2, // 1/2
        LEVEL_3 // Custom
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
        uint256 totalMember;
        uint256 approvalCount;
        uint256 voteStart;
        uint256 voteEnd;
        uint256 createdAt;
        ProposalInfo proposalInfo;
    }

    struct ProposalInfo {
        uint256 numerator;
        uint256 denominator;
        ProposalLevel proposalLevel;
        address[] proposalMemberContracts;
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
     * @param proposalMemberContracts The proposal member
     */
    function registerTransaction(
        uint256 value,
        bytes memory data,
        address to,
        address executor,
        ProposalLevel proposalLevel,
        uint256 voteStart,
        uint256 voteEnd,
        address[] memory proposalMemberContracts
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
     * @param proposalMemberContracts The proposal member
     */
    function registerTransactionWithCustomThreshold(
        uint256 value,
        bytes memory data,
        address to,
        address executor,
        ProposalLevel proposalLevel,
        uint256 numerator,
        uint256 denominator,
        uint256 voteStart,
        uint256 voteEnd,
        address[] memory proposalMemberContracts
    ) external;

    /**
     * @dev Cancel a transaction
     * @param transactionId_ The transaction ID
     */
    function cancelTransaction(uint256 transactionId_) external;
}
