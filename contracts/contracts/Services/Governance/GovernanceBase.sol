// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {IGovernanceService} from "./interfaces/IGovernanceService.sol";
import {SCT} from "../../SCT/functions/SCT.sol";
import {ILETSBase} from "../LETS/interfaces/ILETSBase.sol";
import {ServiceType} from "../../utils/ITypes.sol";
import {IErrors} from "../../utils/IErrors.sol";
import {ThresholdLib} from "../../lib/ThresholdLib.sol";

// OpenZeppelin
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title Test smart contract for Borderless.company service
contract GovernanceBase is
    Initializable,
    OwnableUpgradeable,
    IGovernanceService
{
    // ============================================== //
    //                  Storage                      //
    // ============================================== //

    address private _sc;
    uint256 private _transactionId;

    /// @dev Transaction ID => Transaction
    mapping(uint256 => Transaction) private _transactions;
    mapping(uint256 => mapping(address => bool)) private _approvals;

    // ============================================== //
    //                  Modifier                      //
    // ============================================== //

    /**
     * @dev Modifier to check if the caller is the executor of the transaction
     * @param transactionId The transaction ID
     */
    modifier onlyExecutor(uint256 transactionId) {
        require(
            _transactions[transactionId].executor == msg.sender,
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
            !_approvals[transactionId][msg.sender],
            AlreadyApproved(msg.sender, transactionId)
        );
        _;
    }

    /**
     * @dev Modifier to check if the caller is the Smart Company (SC) Contract or Legal Embedded Token Service (LETS) Contract
     * @param _to The address to check
     */
    modifier onlySCorLETS(address _to) {
        require(
            _to == _sc || _to == SCT(_sc).getService(ServiceType.LETS_EXE),
            NotSCorLETS(msg.sender)
        );
        _;
    }

    modifier onlyGovernanceContract() {
        require(msg.sender == address(this), NotGovernanceContract(msg.sender));
        _;
    }

    /**
     * @dev Modifier to check if the current block timestamp is in the vote period
     * @param transactionId_ The transaction ID
     */
    modifier onlyVotePeriod(uint256 transactionId_) {
        Transaction memory transaction = _transactions[transactionId_];
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
        Transaction memory transaction = _transactions[transactionId];

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
        uint256[] memory tokens = ILETSBase(_sc).getTokensOfOwner(msg.sender);
        for (uint256 i = 0; i < tokens.length; i++) {
            if (ILETSBase(_sc).getUpdatedToken(tokens[i]) <= block.timestamp) {
                isTokenHolder = true;
                break;
            }
        }
        require(isTokenHolder, IErrors.NotTokenHolder(msg.sender));
        _;
    }

    // ============================================== //
    //                  Constructor                   //
    // ============================================== //

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ============================================== //
    //                  Initializer                   //
    // ============================================== //

    function __GovernanceBase_init(
        address owner,
        address sc,
        bytes memory
    ) internal initializer {
        __Ownable_init(owner);
        _sc = sc;
    }

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    function execute(
        uint256 transactionId
    ) external onlyExecutor(transactionId) thresholdReached(transactionId) {
        Transaction memory transaction = _transactions[transactionId];
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
        _approvals[transactionId][msg.sender] = true;
        _transactions[transactionId].approvalCount++;
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
    )
        external
        override
        onlySCorLETS(to)
        checkProposalLevel(proposalLevel, false)
    {
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
    )
        external
        onlySCorLETS(to)
        checkProposalLevel(proposalLevel, true)
    {
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

    function cancelTransaction(
        uint256 transactionId_
    ) external onlyGovernanceContract {
        _transactions[transactionId_].cancelled = true;
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
        uint256 transactionId = _transactionId++;
        _transactions[transactionId] = Transaction({
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

    // ============================================== //
    //             Internal Read Functions            //
    // ============================================== //
}
