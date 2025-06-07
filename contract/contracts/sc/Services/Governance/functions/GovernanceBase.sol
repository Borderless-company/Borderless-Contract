// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// lib
import {GovernanceBaseLib} from "../libs/GovernanceBaseLib.sol";
import {GovernanceInitializeLib} from "../libs/GovernanceInitializeLib.sol";
import {ThresholdLib} from "../../../../core/lib/ThresholdLib.sol";
import {LETSBaseLib} from "../../LETS/libs/LETSBaseLib.sol";

// interfaces
import {IGovernanceService} from "../interfaces/IGovernanceService.sol";
import {IERC721} from "../../../ERC721/interfaces/IERC721.sol";
import {IErrors} from "../../../../core/utils/IErrors.sol";

/**
 * @title GovernanceBase
 * @notice This contract is the base contract for the Governance service
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
            GovernanceBaseLib.getTransaction(transactionId).executor ==
                msg.sender,
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
            !GovernanceBaseLib.getApproval(transactionId, msg.sender),
            AlreadyApproved(msg.sender, transactionId)
        );
        _;
    }

    /**
     * @dev MODIFIER to check if the current block timestamp is in the vote period
     * @param transactionId_ The transaction ID
     */
    modifier onlyVotePeriod(uint256 transactionId_) {
        Transaction memory transaction = GovernanceBaseLib.getTransaction(
            transactionId_
        );
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
        Transaction memory transaction = GovernanceBaseLib.getTransaction(
            transactionId
        );

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
        Transaction memory transaction = GovernanceBaseLib.getTransaction(
            transactionId
        );
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
        virtual
        override
        onlyExecutor(transactionId)
        thresholdReached(transactionId)
    {
        GovernanceBaseLib.execute(transactionId);
    }

    function approveTransaction(
        uint256 transactionId
    )
        external
        onceApproved(transactionId)
        onlyVotePeriod(transactionId)
        onlyTokenHolder(transactionId)
    {
        GovernanceBaseLib.approveTransaction(transactionId);
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
        GovernanceBaseLib.registerTransaction(
            value,
            data,
            to,
            executor,
            proposalLevel,
            voteStart,
            voteEnd,
            proposalMemberContracts
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
        GovernanceBaseLib.registerTransactionWithCustomThreshold(
            value,
            data,
            to,
            executor,
            proposalLevel,
            numerator,
            denominator,
            voteStart,
            voteEnd,
            proposalMemberContracts
        );
    }

    function cancelTransaction(uint256 transactionId_) external override {
        GovernanceBaseLib.cancelTransaction(transactionId_);
    }

    // ============================================== //
    //             EXTERNAL READ FUNCTIONS             //
    // ============================================== //

    function getTransaction(
        uint256 transactionId
    ) external view override returns (Transaction memory) {
        return GovernanceBaseLib.getTransaction(transactionId);
    }
}
