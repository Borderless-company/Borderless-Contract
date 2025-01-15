// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {ERC721Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import {ERC721URIStorageUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import {ERC721EnumerableUpgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721EnumerableUpgradeable.sol";
import {SCT} from "../../SCT/SCT.sol";
import {GovernanceBase} from "../Governance/GovernanceBase.sol";

// interfaces
import {ILETSBase} from "./interfaces/ILETSBase.sol";
import {EventLETSBase} from "./interfaces/EventLETSBase.sol";
import {ErrorLETSBase} from "./interfaces/ErrorLETSBase.sol";

// access control
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// upgradeable
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

// library
import {LibString} from "solady/utils/LibString.sol";

/// @title Legal Embedded Token Service
contract LETSBase is
    Initializable,
    ERC721Upgradeable,
    ERC721URIStorageUpgradeable,
    ERC721EnumerableUpgradeable,
    OwnableUpgradeable,
    ILETSBase,
    EventLETSBase,
    ErrorLETSBase
{
    using LibString for uint256;

    // ============================================== //
    //                  Storage                      //
    // ============================================== //

    SCT internal _sc;
    address internal _governance;
    uint256 internal _nextTokenId;
    string public baseURI;
    string public extension;

    mapping(uint256 => bool) private _freezeToken;

    // ============================================== //
    //                  Modifier                      //
    // ============================================== //

    modifier onlyGovernance() {
        require(
            address(_governance) == msg.sender,
            NotGovernance(msg.sender)
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

    function __LETSBase_initialize(
        address _owner,
        address sc_,
        bytes memory _extraParams
    ) internal initializer {
        __Ownable_init(_owner);
        __ERC721Enumerable_init();
        _sc = SCT(sc_);
        (
            string memory _name,
            string memory _symbol,
            string memory _baseURI,
            string memory _extension,
            address governance_
        ) = abi.decode(
                _extraParams,
                (string, string, string, string, address)
            );
        require(
            bytes(_name).length > 0 &&
                bytes(_symbol).length > 0 &&
                bytes(_baseURI).length > 0 &&
                bytes(_extension).length > 0 &&
                governance_ != address(0),
            InvalidParam(
                msg.sender,
                _name,
                _symbol,
                _baseURI,
                _extension,
                governance_
            )
        );
        __ERC721_init(_name, _symbol);
        baseURI = _baseURI;
        extension = _extension;
    }

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    function mint(address to, uint256 tokenId) public virtual {
        _safeMint(to, tokenId);
        string memory _uri = string.concat(tokenId.toString(), extension);
        _setTokenURI(tokenId, _uri);
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
        return super._update(to, tokenId, auth);
    }

    // ============================================== //
    //             External Read Functions            //
    // ============================================== //

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

    function totalSupply()
        public
        view
        override(ILETSBase, ERC721EnumerableUpgradeable)
        returns (uint256)
    {
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
