// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IGovernanceServiceStructs} from "./IGovernanceServiceStructs.sol";

interface IGovernanceServiceFunctions {
    // ============================================== //
    //           EXTERNAL WRITE FUNCTIONS             //
    // ============================================== //

    /**
     * @dev Execute a transaction
     * @param transactionId The transaction ID
     */
    function execute(uint256 transactionId) external;

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
        IGovernanceServiceStructs.ProposalLevel proposalLevel,
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
        IGovernanceServiceStructs.ProposalLevel proposalLevel,
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

    // ============================================== //
    //             EXTERNAL READ FUNCTIONS            //
    // ============================================== //

    /**
     * @dev Get a transaction
     * @param transactionId The transaction ID
     * @return The transaction
     */
    function getTransaction(
        uint256 transactionId
    ) external view returns (IGovernanceServiceStructs.Transaction memory);
}
