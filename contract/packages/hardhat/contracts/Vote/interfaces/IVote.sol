// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

interface IVote {
	// ============================================== //
	//                    Errors                      //
	// ============================================== //

	error NotDuringVotingPeriod(string proposalId);

	error NotAfterVotingEnded(string proposalId);

	error InvalidEndTime(string proposalId);

	// ============================================== //
	//                    Events                      //
	// ============================================== //

	event ProposalCreated(string proposalId, Proposal proposal);

	event Voted(address indexed voter, string proposalId, VoteType voteType);

	event ProposalExecuted(string proposalId);

	// ============================================== //
	//                     Enums                      //
	// ============================================== //

	enum VoteType {
		Agree,
		Disagree,
		Abstain
	}

	// ============================================== //
	//                   Struct                       //
	// ============================================== //

	struct Proposal {
		address executor; // 実行アドレス
		address tokenContract; // トークンアドレス
		uint256 totalTokenAmount; // トークン総量
		uint256 quorum; // 定足数
		uint256 threshold; // 表決数
		uint256 startTime; // 開始時間
		uint256 endTime; // 終了時間
		uint256 agree; // 賛成票
		uint256 disagree; // 反対票
		uint256 abstain; // 棄権票
	}

	// ============================================== //
	//                   External Functions            //
	// ============================================== //

	function createProposal(
		address executor,
		string memory proposalId,
		uint256 quorum,
		uint256 threshold,
		uint256 startTime,
		uint256 endTime
	) external;

	function vote(string memory proposalId, VoteType voteType) external;
}
