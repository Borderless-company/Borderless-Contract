// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage as GovernanceStorage} from "../storages/Storage.sol";

// lib
import {GovernanceInitializeLib} from "../libs/GovernanceInitializeLib.sol";
import {ThresholdLib} from "../../../../core/lib/ThresholdLib.sol";
import {LETSBaseLib} from "../../LETS/libs/LETSBaseLib.sol";

// interfaces
import {IGovernanceService} from "../interfaces/IGovernanceService.sol";
import {IERC721} from "../../../ERC721/interfaces/IERC721.sol";
import {IErrors} from "../../../../core/utils/IErrors.sol";

/**
 * @title Test smart contract for Borderless.company service
 * @notice This contract is used to test the Governance service
 */
contract GovernanceBase is IGovernanceService {
    // ============================================== //
    //                  MODIFIER                      //
    // ============================================== //

    /**
     * @dev MODIFIER to check if the caller is the executor of the transaction
     * @param transactionId The transaction ID
     */
    modifier onlyExecutor(uint256 transactionId) {
        require(
            GovernanceStorage
                .GovernanceSlot()
                .transactions[transactionId]
                .executor == msg.sender,
            NotExecutor(msg.sender, transactionId)
        );
        _;
    }

    /**
     * @dev MODIFIER to check if the caller has already approved the transaction
     * @param transactionId The transaction ID
     */
    modifier onceApproved(uint256 transactionId) {
        require(
            !GovernanceStorage.GovernanceSlot().approvals[transactionId][
                msg.sender
            ],
            AlreadyApproved(msg.sender, transactionId)
        );
        _;
    }

    /**
     * @dev MODIFIER to check if the current block timestamp is in the vote period
     * @param transactionId_ The transaction ID
     */
    modifier onlyVotePeriod(uint256 transactionId_) {
        Transaction memory transaction = GovernanceStorage
            .GovernanceSlot()
            .transactions[transactionId_];
        require(
            block.timestamp >= transaction.voteStart &&
                block.timestamp <= transaction.voteEnd,
            NotInVotePeriod(transactionId_)
        );
        _;
    }

    /**
     * @dev MODIFIER to check if the threshold is reached
     * @param transactionId The transaction ID
     */
    modifier thresholdReached(uint256 transactionId) {
        Transaction memory transaction = GovernanceStorage
            .GovernanceSlot()
            .transactions[transactionId];

        require(
            transaction.approvalCount >=
                ThresholdLib.getCustomThreshold(
                    transaction.totalMember,
                    transaction.proposalInfo.numerator,
                    transaction.proposalInfo.denominator
                ),
            ThresholdNotReached(transactionId)
        );
        _;
    }

    modifier checkProposalLevel(ProposalLevel proposalLevel, bool isCustom) {
        require(
            isCustom
                ? proposalLevel >= ProposalLevel.LEVEL_3
                : proposalLevel == ProposalLevel.LEVEL_1 ||
                    proposalLevel == ProposalLevel.LEVEL_2,
            InvalidProposalLevel(proposalLevel)
        );
        _;
    }

    modifier onlyTokenHolder(uint256 transactionId) {
        bool isTokenHolder = false;
        Transaction memory transaction = GovernanceStorage
            .GovernanceSlot()
            .transactions[transactionId];
        address[] memory tokenContracts = transaction
            .proposalInfo
            .proposalMemberContracts;
        for (uint256 i = 0; i < tokenContracts.length; i++) {
            uint256[] memory tokenIds = IERC721(tokenContracts[i])
                .getTokensOfOwner(msg.sender);
            for (uint256 j = 0; j < tokenIds.length; j++) {
                if (
                    LETSBaseLib.getUpdatedToken(tokenIds[j]) <= block.timestamp
                ) {
                    isTokenHolder = true;
                    break;
                }
            }
            if (isTokenHolder) {
                break;
            }
        }
        require(isTokenHolder, IErrors.NotTokenHolder(msg.sender));
        _;
    }

    // ============================================== //
    //                  INITIALIZE                 //
    // ============================================== //

    function initialize(address dictionary) external {
        GovernanceInitializeLib.initialize(dictionary);
    }

    // ============================================== //
    //             EXTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    function execute(
        uint256 transactionId
    )
        external
        override
        onlyExecutor(transactionId)
        thresholdReached(transactionId)
    {
        // Transaction memory transaction = GovernanceStorage
        //     .GovernanceSlot()
        //     .transactions[transactionId];
        // (bool success, ) = transaction.to.call{value: transaction.value}(
        //     transaction.data
        // );
        // require(success, ExecuteFailed(transactionId));
        GovernanceStorage
            .GovernanceSlot()
            .transactions[transactionId]
            .executed = true;
        emit TransactionExecuted(transactionId);
    }

    function approveTransaction(
        uint256 transactionId
    )
        external
        onceApproved(transactionId)
        onlyVotePeriod(transactionId)
        onlyTokenHolder(transactionId)
    {
        GovernanceStorage.GovernanceSlot().approvals[transactionId][
            msg.sender
        ] = true;
        GovernanceStorage
            .GovernanceSlot()
            .transactions[transactionId]
            .approvalCount++;
        emit TransactionApproved(transactionId, msg.sender);
    }

    function registerTransaction(
        uint256 value,
        bytes memory data,
        address to,
        address executor,
        ProposalLevel proposalLevel,
        uint256 voteStart,
        uint256 voteEnd,
        address[] memory proposalMemberContracts
    ) external override checkProposalLevel(proposalLevel, false) {
        ProposalInfo memory proposalInfo = ProposalInfo({
            numerator: proposalLevel == ProposalLevel.LEVEL_1 ? 2 : 1, // 2/3 or 1/2
            denominator: proposalLevel == ProposalLevel.LEVEL_1 ? 3 : 2, // 2/3 or 1/2
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
        ProposalLevel proposalLevel,
        uint256 numerator,
        uint256 denominator,
        uint256 voteStart,
        uint256 voteEnd,
        address[] memory proposalMemberContracts
    ) external override checkProposalLevel(proposalLevel, true) {
        require(
            numerator > 0 && denominator > 0,
            InvalidNumeratorOrDenominator(numerator, denominator)
        );
        ProposalInfo memory proposalInfo = ProposalInfo({
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

    function cancelTransaction(uint256 transactionId_) external override {
        GovernanceStorage
            .GovernanceSlot()
            .transactions[transactionId_]
            .cancelled = true;
        emit TransactionCancelled(transactionId_);
    }

    // ============================================== //
    //             EXTERNAL READ FUNCTIONS             //
    // ============================================== //

    function getTransaction(
        uint256 transactionId
    ) external view override returns (Transaction memory) {
        return GovernanceStorage.GovernanceSlot().transactions[transactionId];
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
        ProposalInfo memory proposalInfo
    ) internal {
        GovernanceStorage.GovernanceSlot().lastTransactionId++;
        uint256 transactionId = GovernanceStorage
            .GovernanceSlot()
            .lastTransactionId;
        GovernanceStorage.GovernanceSlot().transactions[
            transactionId
        ] = Transaction({
            value: value,
            data: data,
            to: to,
            executor: executor,
            executed: false,
            cancelled: false,
            totalMember: proposalInfo.proposalMemberContracts.length,
            approvalCount: 0,
            voteStart: voteStart,
            voteEnd: voteEnd,
            createdAt: block.timestamp,
            proposalInfo: proposalInfo
        });
        emit TransactionCreated(transactionId);
    }
}
