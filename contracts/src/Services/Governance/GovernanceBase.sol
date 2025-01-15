// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {IGovernanceService} from "./interfaces/IGovernanceService.sol";
import {ErrorGovernanceService} from "./interfaces/ErrorGovernanceService.sol";
import {EventGovernanceService} from "./interfaces/EventGovernanceService.sol";
import {ILETSBase} from "../LETS/interfaces/ILETSBase.sol";
import {SCT} from "../../SCT/SCT.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// Ownable
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// Initializable
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// library
import {ThresholdLib} from "../../lib/ThresholdLib.sol";

/// @title Test smart contract for Borderless.company service
contract GovernanceBase is
    Initializable,
    OwnableUpgradeable,
    IGovernanceService,
    ErrorGovernanceService,
    EventGovernanceService
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
     * @dev Modifier to check if the caller is an execution member
     */
    modifier onlyExecutionMember() {
        require(
            IERC721(_sc).balanceOf(msg.sender) > 0,
            NotExecutionMember(msg.sender)
        );
        _;
    }

    /**
     * @dev Modifier to check if the caller is the executor of the transaction
     * @param transactionId_ The transaction ID
     */
    modifier onlyExecutor(uint256 transactionId_) {
        require(
            _transactions[transactionId_].executor == msg.sender,
            NotExecutor(msg.sender, transactionId_)
        );
        _;
    }

    /**
     * @dev Modifier to check if the caller has already approved the transaction
     * @param transactionId_ The transaction ID
     */
    modifier onceApproved(uint256 transactionId_) {
        require(
            !_approvals[transactionId_][msg.sender],
            AlreadyApproved(msg.sender, transactionId_)
        );
        _;
    }

    /**
     * @dev Modifier to check if the caller is the Smart Company (SC) Contract or Legal Embedded Token Service (LETS) Contract
     * @param _to The address to check
     */
    modifier onlySCorLETS(address _to) {
        require(_to == _sc || _to == SCT(_sc).letsExe(), NotSCorLETS(msg.sender));
        _;
    }

    modifier onlyGovernanceContract() {
        require(
            msg.sender == address(this),
            NotGovernanceContract(msg.sender)
        );
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
     * @param transactionId_ The transaction ID
     */
    modifier thresholdReached(uint256 transactionId_) {
        Transaction memory transaction = _transactions[transactionId_];
        uint256 executeMemberCount = ILETSBase(SCT(_sc).letsExe()).totalSupply();
        uint256 totalApprovedMember = 0;

        if (
            transaction.proposalInfo.proposalMember ==
            ProposalMember.EXECUTIONS_MEMBER
        ) {
            totalApprovedMember = executeMemberCount;
        } else if (
            transaction.proposalInfo.proposalMember == ProposalMember.MEMBER
        ) {
            totalApprovedMember = ILETSBase(SCT(_sc).letsNonExe()).totalSupply();
        }

        require(
            transaction.approvalCount >=
                ThresholdLib.getCustomThreshold(
                    totalApprovedMember,
                    transaction.proposalInfo.numerator,
                    transaction.proposalInfo.denominator
                ),
            ThresholdNotReached(transactionId_)
        );
        _;
    }

    modifier checkProposalLevel(uint8 proposalLevel, bool isCustom) {
        require(
            isCustom
                ? proposalLevel >= 3
                : proposalLevel == 1 || proposalLevel == 2,
            InvalidProposalLevel(proposalLevel)
        );
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
        address _owner,
        address sc_,
        bytes memory
    ) internal initializer {
        __Ownable_init(_owner);
        _sc = sc_;
    }

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    function execute(
        uint256 transactionId_
    ) external onlyExecutor(transactionId_) thresholdReached(transactionId_) {
        Transaction memory transaction = _transactions[transactionId_];
        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, ExecuteFailed(transactionId_));
        emit TransactionExecuted(transactionId_);
    }

    function approveTransaction(
        uint256 transactionId_
    )
        external
        onceApproved(transactionId_)
        onlyExecutionMember
        onlyVotePeriod(transactionId_)
    {
        _approvals[transactionId_][msg.sender] = true;
        _transactions[transactionId_].approvalCount++;
        emit TransactionApproved(transactionId_, msg.sender);
    }

    function registerTransaction(
        uint256 value,
        bytes memory data,
        address to,
        address executor,
        uint8 proposalLevel,
        uint256 voteStart,
        uint256 voteEnd
    )
        external
        onlyExecutionMember
        onlySCorLETS(to)
        checkProposalLevel(proposalLevel, false)
    {
        ProposalInfo memory proposalInfo = ProposalInfo({
            numerator: proposalLevel == 1 ? 2 : 1,
            denominator: proposalLevel == 1 ? 3 : 2,
            proposalLevel: proposalLevel,
            proposalMember: proposalLevel == 1
                ? ProposalMember.EXECUTIONS_MEMBER
                : ProposalMember.MEMBER
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
        uint8 proposalLevel,
        uint256 numerator,
        uint256 denominator,
        uint256 voteStart,
        uint256 voteEnd,
        ProposalMember proposalMember
    )
        external
        onlyExecutionMember
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
            proposalMember: proposalMember
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
