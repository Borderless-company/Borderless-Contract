// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import { IVote } from "./interfaces/IVote.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import { IERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {console} from "forge-std/console.sol";
import {ILETSBase} from "../Services/LETS/interfaces/ILETSBase.sol";

contract Vote is IVote, Initializable, UUPSUpgradeable, OwnableUpgradeable {
	// ============================================== //
	//                  Storage                      //
	// ============================================== //

	mapping(string => Proposal) public proposals;

	mapping(string => mapping(address => bool)) public voted;

	address public nftContract;
	bool private isOwnerChanged;

	// ============================================== //
	//                  Modifier                      //
	// ============================================== //

	modifier onlyDuringVotingPeriod(string memory proposalId) {
		require(
			block.timestamp >= proposals[proposalId].startTime &&
				block.timestamp <= proposals[proposalId].endTime,
			NotDuringVotingPeriod(proposalId)
		);
		_;
	}

	modifier onlyAfterVotingEnded(string memory proposalId) {
		require(
			block.timestamp > proposals[proposalId].endTime,
			NotAfterVotingEnded(proposalId)
		);
		_;
	}

	// ============================================== //
	//                  Initialize                    //
	// ============================================== //

	function initialize(address _nftContract) external initializer {
		__Ownable_init(msg.sender);
		nftContract = _nftContract;
		console.log("initialize nftContract", nftContract);
		console.log("initialize ILETSBase(nftContract).totalSupply()", ILETSBase(nftContract).totalSupply());
	}

	// ============================================== //
	//                EXTERNAL WRITE                  //
	// ============================================== //

	function createProposal(
		address executor,
		string memory proposalId,
		uint256 quorum,
		uint256 threshold,
		uint256 startTime,
		uint256 endTime
	) external {
		require(endTime > startTime, InvalidEndTime(proposalId));

		console.log("nftContract", nftContract);
		console.log("ILETSBase(nftContract).totalSupply()", ILETSBase(nftContract).totalSupply());

		Proposal memory newProposal = Proposal(
			executor,
			nftContract,
			ILETSBase(nftContract).totalSupply(),
			quorum,
			threshold,
			startTime,
			endTime,
			0,
			0,
			0
		);

		proposals[proposalId] = newProposal;

		emit ProposalCreated(proposalId, newProposal);
	}

	function vote(
		string calldata proposalId,
		VoteType voteType
	) external onlyDuringVotingPeriod(proposalId) {
		Proposal storage proposal = proposals[proposalId];

		require(!voted[proposalId][msg.sender], "Already voted");

		if (voteType == VoteType.Agree) {
			proposal.agree++;
		} else if (voteType == VoteType.Disagree) {
			proposal.disagree++;
		} else {
			proposal.abstain++;
		}
		voted[proposalId][msg.sender] = true;

		emit Voted(msg.sender, proposalId, voteType);
	}

	// ============================================== //
	//                  UUPS                      //
	// ============================================== //

	function _authorizeUpgrade(address newImplementation)
		internal
		override
		onlyOwner
	{}
}
