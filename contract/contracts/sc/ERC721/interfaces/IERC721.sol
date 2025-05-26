// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// OpenZeppelin
import {IERC721 as OZIERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Metadata} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import {IERC4906} from "@openzeppelin/contracts/interfaces/IERC4906.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";

/**
 * @title IERC721
 * @dev Interface for the ERC721 standard
 */
interface IERC721 is
    IERC165,
    OZIERC721,
    IERC721Metadata,
    IERC721Enumerable,
    IERC4906,
    IERC721Errors
{
    /**
     * @dev Returns the tokens of the owner
     * @param owner The address of the owner
     * @return The tokens of the owner
     */
    function getTokensOfOwner(
        address owner
    ) external view returns (uint256[] memory);
}
