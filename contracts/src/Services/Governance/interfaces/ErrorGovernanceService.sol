// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

interface ErrorGovernanceService {
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
    error InvalidProposalLevel(uint8 proposalLevel);

    /**
     * @dev Error when the numerator or denominator is invalid
     * @param numerator The numerator
     * @param denominator The denominator
     */
    error InvalidNumeratorOrDenominator(uint256 numerator, uint256 denominator);
}
