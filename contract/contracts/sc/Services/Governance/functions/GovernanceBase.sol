// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage as GovernanceStorage} from "../storages/Storage.sol";
import {Storage as LETSBaseStorage} from "../../LETS/storages/Storage.sol";

// lib
import {GovernanceInitializeLib} from "../libs/GovernanceInitializeLib.sol";
import {ThresholdLib} from "../../../../core/lib/ThresholdLib.sol";
import {LETSBaseLib} from "../../LETS/libs/LETSBaseLib.sol";
import {ERC721Lib} from "../../../ERC721/libs/ERC721Lib.sol";

// interfaces
import {IGovernanceService} from "../interfaces/IGovernanceService.sol";
import {IErrors} from "../../../../core/utils/IErrors.sol";

/**
 * @title Test smart contract for Borderless.company service
 */
contract GovernanceBase is IGovernanceService {
    // ============================================== //
    //                  Modifier                      //
    // ============================================== //

    /**
     * @dev Modifier to check if the caller is the executor of the transaction
     * @param transactionId The transaction ID
     */
    modifier onlyExecutor(uint256 transactionId) {
        require(
            GovernanceStorage.GovernanceSlot().transactions[transactionId]
                .executor == msg.sender,
            NotExecutor(msg.sender, transactionId)
        );
        _;
    }

    /**
     * @dev Modifier to check if the caller has already approved the transaction
     * @param transactionId The transaction ID
     */
    modifier onceApproved(uint256 transactionId) {
        require(
            !GovernanceStorage.GovernanceSlot().approvals[transactionId][msg.sender],
            AlreadyApproved(msg.sender, transactionId)
        );
        _;
    }

    /**
     * @dev Modifier to check if the current block timestamp is in the vote period
     * @param transactionId_ The transaction ID
     */
    modifier onlyVotePeriod(uint256 transactionId_) {
        Transaction memory transaction = GovernanceStorage.GovernanceSlot().transactions[
            transactionId_
        ];
        require(
            block.timestamp >= transaction.voteStart &&
                block.timestamp <= transaction.voteEnd,
            NotInVotePeriod(transactionId_)
        );
        _;
    }

    /**
     * @dev Modifier to check if the threshold is reached
     * @param transactionId The transaction ID
     */
    modifier thresholdReached(uint256 transactionId) {
        Transaction memory transaction = GovernanceStorage.GovernanceSlot().transactions[
            transactionId
        ];

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

    modifier onlyTokenHolder() {
        bool isTokenHolder = false;
        uint256[] memory tokens = ERC721Lib.getTokensOfOwner(
            msg.sender
        );
        for (uint256 i = 0; i < tokens.length; i++) {
            if (LETSBaseLib.getUpdatedToken(tokens[i]) <= block.timestamp) {
                isTokenHolder = true;
                break;
            }
        }
        require(isTokenHolder, IErrors.NotTokenHolder(msg.sender));
        _;
    }

    // ============================================== //
    //                  Initialization                 //
    // ============================================== //

    function initialize(address dictionary) external {
        GovernanceInitializeLib.initialize(dictionary);
    }

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    function execute(
        uint256 transactionId
    ) external onlyExecutor(transactionId) thresholdReached(transactionId) {
        Transaction memory transaction = GovernanceStorage.GovernanceSlot().transactions[
            transactionId
        ];
        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, ExecuteFailed(transactionId));
        emit TransactionExecuted(transactionId);
    }

    function approveTransaction(
        uint256 transactionId
    )
        external
        onceApproved(transactionId)
        onlyVotePeriod(transactionId)
        onlyTokenHolder
    {
        GovernanceStorage.GovernanceSlot().approvals[transactionId][msg.sender] = true;
        GovernanceStorage.GovernanceSlot().transactions[transactionId].approvalCount++;
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
    ) external checkProposalLevel(proposalLevel, true) {
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

    function cancelTransaction(uint256 transactionId_) external {
        GovernanceStorage.GovernanceSlot().transactions[transactionId_].cancelled = true;
        emit TransactionCancelled(transactionId_);
    }

    // ============================================== //
    //             Internal Write Functions           //
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
        uint256 transactionId = GovernanceStorage.GovernanceSlot().lastTransactionId++;
        GovernanceStorage.GovernanceSlot().transactions[transactionId] = Transaction({
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
