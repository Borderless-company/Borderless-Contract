// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {OwnableFacade} from "../../../../core/Ownable/facades/OwnableFacade.sol";
import {ERC721Facade} from "../../../ERC721/facades/ERC721Facade.sol";

// interfaces
import {ILETSBase} from "../interfaces/ILETSBase.sol";

/**
 * @title LETSBaseFacade
 * @notice Proxy contract for the LETSBase contract
 */
contract LETSBaseFacade is OwnableFacade, ERC721Facade, ILETSBase {
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

    function getSC() external view returns (address) {}

    function getIsMetadataFixed() external view returns (bool) {}

    function getNextTokenId() external view returns (uint256) {}

    function getMaxSupply() external view returns (uint256) {}

    function getBaseURI() external view returns (string memory) {}

    function getExtension() external view returns (string memory) {}

    function getFreezeToken(uint256 tokenId) external view returns (bool) {}

    function getUpdatedToken(
        uint256 tokenId
    ) external view override returns (uint256) {}
}
