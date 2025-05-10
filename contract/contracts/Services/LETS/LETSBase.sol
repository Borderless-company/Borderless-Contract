// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {SCT} from "../../SCT/functions/SCT.sol";
import {ILETSBase} from "./interfaces/ILETSBase.sol";
import {IErrors} from "../../utils/IErrors.sol";

// OpenZeppelin
import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {ERC721URIStorageUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {ERC721EnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// library
import {LibString} from "solady/src/utils/LibString.sol";
import {console} from "hardhat/console.sol";

/// @title Legal Embedded Token Service
contract LETSBase is
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    ERC721EnumerableUpgradeable,
    OwnableUpgradeable,
    ILETSBase
{
    using LibString for uint256;

    // ============================================== //
    //                  Storage                      //
    // ============================================== //

    SCT internal _sc;
    address internal _letsSale;
    address internal _governance;
    uint256 internal _nextTokenId;
    string public baseURI;
    string public extension;

    /**
     * @dev freeze the token
     */
    mapping(uint256 => bool) internal _freezeToken;

    /**
     * @dev timestamp of the mint or transfer of the token
     */
    mapping(uint256 => uint256) internal _updatedToken;

    // ============================================== //
    //                  Modifier                      //
    // ============================================== //

    modifier onlyGovernance() {
        require(address(_governance) == msg.sender, NotGovernance(msg.sender));
        _;
    }

    modifier onlyLetsSale() {
        require(_letsSale == msg.sender, NotLetsSale(msg.sender));
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

    function __LETSBase_initialize(
        address owner,
        address sc,
        bytes memory params
    ) internal initializer {
        console.log("LETSBase initialize");
        __Ownable_init(owner);
        __ERC721Enumerable_init();
        _sc = SCT(sc);
        (
            string memory name,
            string memory symbol,
            string memory baseURI_,
            string memory extension_,
            address governance,
            address letsSale
        ) = abi.decode(
                params,
                (string, string, string, string, address, address)
            );
        console.log("LETSBase initialize 0");
        console.log("name", name);
        console.log("symbol", symbol);
        console.log("baseURI", baseURI_);
        console.log("extension", extension_);
        console.log("letsSale", letsSale);
        console.log("governance", governance);
        require(
            bytes(name).length > 0 &&
                bytes(symbol).length > 0 &&
                bytes(baseURI_).length > 0 &&
                bytes(extension_).length > 0 &&
                letsSale != address(0) &&
                governance != address(0),
            IErrors.InvalidParam(bytes32(params))
        );
        console.log("LETSBase initialize 1");
        __ERC721_init(name, symbol);
        console.log("LETSBase initialize 2");
        baseURI = baseURI_;
        extension = extension_;
        _letsSale = letsSale;
        _governance = governance;
        console.log("LETSBase initialize 3");
        console.log("LETSBase initialize done");
    }

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    function mint(address to, uint256 tokenId) public virtual onlyGovernance {
        _safeMint(to, tokenId);
    }

    function mint(
        address to
    ) public override onlyLetsSale returns (uint256 tokenId) {
        tokenId = ++_nextTokenId;
        _safeMint(to, tokenId);
    }

    function freezeToken(uint256 tokenId) public onlyGovernance {
        _freezeToken[tokenId] = true;
        emit TokenFrozen(tokenId);
    }

    function unfreezeToken(uint256 tokenId) public onlyGovernance {
        _freezeToken[tokenId] = false;
        emit TokenUnfrozen(tokenId);
    }

    // ============================================== //
    //             Internal Write Functions           //
    // ============================================== //

    function _increaseBalance(
        address account,
        uint128 amount
    ) internal override(ERC721Upgradeable, ERC721EnumerableUpgradeable) {
        super._increaseBalance(account, amount);
    }

    // ============================================== //
    //             Eternal Read Functions             //
    // ============================================== //

    function getSC() external view returns (address) {
        return address(_sc);
    }

    function getLetsSale() external view returns (address) {
        return _letsSale;
    }

    function getUpdatedToken(uint256 tokenId) external view returns (uint256) {
        return _updatedToken[tokenId];
    }

    function getTokensOfOwner(
        address owner
    ) external view returns (uint256[] memory) {
        uint256 count = balanceOf(owner);
        uint256[] memory tokenIds = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(owner, i);
        }
        return tokenIds;
    }

    // ============================================== //
    //             ERC721 Overrides                   //
    // ============================================== //

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        virtual
        override(ERC721Upgradeable, ERC721EnumerableUpgradeable)
        returns (address)
    {
        if (to != address(0)) {
            _updatedToken[tokenId] = block.timestamp;
        }
        return super._update(to, tokenId, auth);
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal override {
        string memory _uri = string.concat(tokenId.toString(), extension);
        _setTokenURI(tokenId, _uri);
        super._safeMint(to, tokenId, data);
    }

    function tokenURI(
        uint256 tokenId
    )
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function totalSupply() public view override returns (uint256) {
        return super.totalSupply();
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(
            ERC721Upgradeable,
            ERC721URIStorageUpgradeable,
            ERC721EnumerableUpgradeable
        )
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
