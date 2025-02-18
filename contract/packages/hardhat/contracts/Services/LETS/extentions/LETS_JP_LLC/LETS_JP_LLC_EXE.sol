// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import { LETSBase } from "../../LETSBase.sol";
import { ILETS_JP_LLC_EXE } from "./interfaces/ILETS_JP_LLC_EXE.sol";

// upgradeable
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "forge-std/console.sol";

/// @title Legal Embedded Token Service
contract LETS_JP_LLC_EXE is
	Initializable,
	LETSBase,
	ILETS_JP_LLC_EXE
{
	// ============================================== //
    //                    Storage                     //
    // ============================================== //

	mapping(uint256 => address) private _mintReserve;

	// ============================================== //
    //                  Modifier                      //
    // ============================================== //

    modifier onlyMintReserve(uint256 tokenId) {
        require(
            _mintReserve[tokenId] == msg.sender,
            NotMintReserve(msg.sender)
        );
        _;
    }

	modifier restrictTransfer(uint256 tokenId) {
        console.log("tokenId", tokenId);
        console.log("_ownerOf(tokenId)", _ownerOf(tokenId));
        if (_ownerOf(tokenId) != address(0)) {
            require(
                msg.sender == _governance,
                NotTransferable()
            );
        }
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

	function initialize(
		address _owner,
		address _register,
		bytes calldata _extraParams
	) external initializer {
		__LETSBase_initialize(_owner, _register, _extraParams);
       uint256 tokenId = ++_nextTokenId;
       mint_(_owner, tokenId);
	}

	// ============================================== //
    //             External Write Functions           //
    // ============================================== //

    function mint(
        address to,
        uint256 tokenId
    ) public override onlyMintReserve(tokenId) {
		super.mint(to, tokenId);
    }

	function setMintReserve(address to) public onlyGovernance {
        uint256 tokenId = _nextTokenId++;
        _mintReserve[tokenId] = to;
        emit MintReserveSet(tokenId, to);
    }

	// ============================================== //
    //             Internal Write Functions           //
    // ============================================== //

    function _update(
        address to,
        uint256 tokenId,
        address auth
    )
        internal
        override
        restrictTransfer(tokenId)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }
}
