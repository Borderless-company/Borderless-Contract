// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC4906} from "@openzeppelin/contracts/interfaces/IERC4906.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {IOwnable} from "../../../sc/Ownable/interfaces/IOwnable.sol";
import {IDictionary} from "../../Dictionary/interfaces/IDictionary.sol";
import {ILETSBase} from "../../../sc/Services/LETS/interfaces/ILETSBase.sol";
import {ILETSSaleBase} from "../../../sc/Services/LETS/interfaces/ILETSSaleBase.sol";
import {IGovernanceService} from "../../../sc/Services/Governance/interfaces/IGovernanceService.sol";
import {IAOI} from "../../../sc/Services/AOI/interfaces/IAOI.sol";
import {ServiceType} from "../../utils/ITypes.sol";

contract SCProxy {
    // From ERC721
    function balanceOf(address owner) external view returns (uint256) {}
    function ownerOf(uint256 tokenId) external view returns (address) {}
    function approve(address to, uint256 tokenId) external {}
    function getApproved(uint256 tokenId) external view returns (address) {}
    function setApprovalForAll(address operator, bool approved) external {}
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool) {}
    function transferFrom(address from, address to, uint256 tokenId) external {}
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external {}
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) external {}

    // From ERC721Metadata
    function name() external view returns (string memory) {}
    function symbol() external view returns (string memory) {}
    function tokenURI(uint256 tokenId) external view returns (string memory) {}

    // From ERC721Enumerable
    function totalSupply() external view returns (uint256) {}
    function tokenByIndex(uint256 index) external view returns (uint256) {}
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) external view returns (uint256) {}
    function getTokensOfOwner(
        address owner
    ) external view returns (uint256[] memory) {}

    // From BorderlessAccessControl
    function initialize(address dictionary) external {}
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32) {}
    function grantRole(bytes32 role, address account) external {}
    function revokeRole(bytes32 role, address account) external {}
    function renounceRole(bytes32 role, address callerConfirmation) external {}
    function getRoleAdmin(bytes32 role) external view returns (bytes32) {}
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool) {}
    function supportsInterface(
        bytes4 interfaceId
    ) external view returns (bool) {}

    // From Dictionary
    function setImplementation(
        bytes4 selector,
        address implementation
    ) external {}
    function bulkSetImplementation(
        bytes4[] memory selectors,
        address[] memory implementations
    ) external {}
    function upgradeFacade(address newFacade) external {}
    function setOnceInitialized(
        address account,
        address implementation
    ) external {}
    function getFacade() external view returns (address) {}

    // From Ownable
    function owner() external view returns (address) {}
    function renounceOwnership() external {}
    function transferOwnership(address newOwner) external {}

    // From LETSBase
    function mint(address to) external returns (uint256 tokenId) {}
    function freezeToken(uint256 tokenId) external {}
    function unfreezeToken(uint256 tokenId) external {}
    function getUpdatedToken(uint256 tokenId) external view returns (uint256) {}

    // From LETSSaleBase
    function setSaleInfo(
        uint256 saleStart,
        uint256 saleEnd,
        uint256 fixedPrice,
        uint256 minPrice,
        uint256 maxPrice
    ) external {}
    function offerToken(address to) external payable {}
    function withdraw() external {}
    function updateSalePeriod(uint256 saleStart, uint256 saleEnd) external {}
    function updatePrice(
        uint256 fixedPrice,
        uint256 minPrice,
        uint256 maxPrice
    ) external {}

    // From GovernanceBase
    function execute(uint256 transactionId) external {}
    function approveTransaction(uint256 transactionId) external {}
    function registerTransaction(
        uint256 value,
        bytes memory data,
        address to,
        address executor,
        IGovernanceService.ProposalLevel proposalLevel,
        uint256 voteStart,
        uint256 voteEnd,
        address[] memory proposalMemberContracts
    ) external {}
    function registerTransactionWithCustomThreshold(
        uint256 value,
        bytes memory data,
        address to,
        address executor,
        IGovernanceService.ProposalLevel proposalLevel,
        uint256 numerator,
        uint256 denominator,
        uint256 voteStart,
        uint256 voteEnd,
        address[] memory proposalMemberContracts
    ) external {}
    function cancelTransaction(uint256 transactionId) external {}

    // From AOI
    function initialSetChapter(
        IAOI.EncryptedItemInput[] calldata items
    ) external {}
    function setEphemeralSalt(bytes32 ephemeralSalt) external {}
    function getEncryptedItem(
        IAOI.ItemLocation calldata location
    ) external view returns (IAOI.EncryptedItem memory) {}
    function getVersionRoot(
        uint256 versionId
    ) external view returns (bytes32) {}
    function isEphemeralSaltUsed(
        bytes32 ephemeralSalt
    ) external view returns (bool) {}
    function verifyDecryptionKeyHash(
        IAOI.ItemLocation calldata location,
        bytes32 expectedHash
    ) external view returns (bool) {}
    function verifyDecryptionKeyHashWithSaltHash(
        IAOI.ItemLocation calldata location,
        bytes32 ephemeralSalt,
        bytes32 masterSaltHash,
        address holder
    ) external view returns (bool) {}

    // From SCT
    function initialize(address founder, address scr) external {}
    function registerService(
        ServiceType[] calldata serviceTypes,
        address[] calldata services
    ) external returns (bool) {}
    function setInvestmentAmount(
        address account,
        uint256 investmentAmount
    ) external {}
    function getSCR() external view returns (address) {}
    function getService(
        ServiceType serviceType
    ) external view returns (address) {}
    function getInvestmentAmount(
        address account
    ) external view returns (uint256) {}
}
