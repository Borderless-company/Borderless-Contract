// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {OwnableProxy} from "../../../../core/Ownable/proxy/OwnableProxy.sol";
import {ERC721Proxy} from "../../../ERC721/proxy/ERC721Proxy.sol";

// interfaces
import {ILETSBase} from "../interfaces/ILETSBase.sol";

/**
 * @title LETSBaseProxy
 * @notice Proxy contract for the LETSBase contract
 */
contract LETSBaseProxy is OwnableProxy, ERC721Proxy, ILETSBase {
    // ============================================== //
    //             EXTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    function initialize(
        address dictionary,
        address implementation,
        address sc,
        bytes calldata params
    ) external override returns (bytes4[] memory selectors) {}

    function mint(address to) external override {}

    function freezeToken(uint256 tokenId) external override {}

    function unfreezeToken(uint256 tokenId) external override {}

    // ============================================== //
    //             Eternal Read Functions             //
    // ============================================== //

    function getUpdatedToken(
        uint256 tokenId
    ) external view override returns (uint256) {}
}
