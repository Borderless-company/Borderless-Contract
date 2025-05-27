// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {IGovernanceService} from "../interfaces/IGovernanceService.sol";
import {IGovernanceServiceStructs} from "../interfaces/IGovernanceServiceStructs.sol";

/**
 * @title GovernanceServiceProxy
 * @notice Proxy contract for the Governance service
 */
contract GovernanceServiceProxy is IGovernanceService {
    // ============================================== //
    //           EXTERNAL WRITE FUNCTIONS             //
    // ============================================== //

    function execute(uint256 transactionId) external override {}

    function approveTransaction(uint256 transactionId_) external override {}

    function registerTransaction(
        uint256 value,
        bytes memory data,
        address to,
        address executor,
        IGovernanceServiceStructs.ProposalLevel proposalLevel,
        uint256 voteStart,
        uint256 voteEnd,
        address[] memory proposalMemberContracts
    ) external override {}

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
    ) external override {}

    function cancelTransaction(uint256 transactionId_) external override {}

    // ============================================== //
    //             EXTERNAL READ FUNCTIONS            //
    // ============================================== //

    function getTransaction(
        uint256 transactionId
    )
        external
        view
        override
        returns (IGovernanceServiceStructs.Transaction memory)
    {}
}
