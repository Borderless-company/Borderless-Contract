// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IGovernanceServiceStructs {
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
}
