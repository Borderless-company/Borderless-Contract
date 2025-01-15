// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

interface EventGovernanceService {
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
}
