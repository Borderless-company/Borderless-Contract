// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage as ERC721Storage} from "../storages/Storage.sol";
// interfaces
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC721Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC721EnumerableErrors} from "../interfaces/IERC721EnumerableErrors.sol";
import {IERC4906} from "@openzeppelin/contracts/interfaces/IERC4906.sol";
import {ERC721Utils} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Utils.sol";

library ERC721Lib {
    // ============================================== //
    //                 ERC721 Functions               //
    // ============================================== //

    function balanceOf(address owner) internal view returns (uint256) {
        if (owner == address(0))
            revert IERC721Errors.ERC721InvalidOwner(address(0));
        return ERC721Storage.ERC721Slot().balances[owner];
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function baseURI() internal pure returns (string memory) {
        return "";
    }

    /**
     * @dev Returns the owner of the `tokenId`. Does NOT revert if token doesn't exist
     *
     * IMPORTANT: Any overrides to this function that add ownership of tokens not tracked by the
     * core ERC-721 logic MUST be matched with the use of {_increaseBalance} to keep balances
     * consistent with ownership. The invariant to preserve is that for any address `a` the value returned by
     * `balanceOf(a)` must be equal to the number of tokens such that `_ownerOf(tokenId)` is `a`.
     */
    function ownerOf(uint256 tokenId) internal view returns (address) {
        return ERC721Storage.ERC721Slot().owners[tokenId];
    }

    /**
     * @dev Returns the approved address for `tokenId`. Returns 0 if `tokenId` is not minted.
     */
    function getApproved(uint256 tokenId) internal view returns (address) {
        return ERC721Storage.ERC721Slot().tokenApprovals[tokenId];
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `owner`'s tokens, or `tokenId` in
     * particular (ignoring whether it is owned by `owner`).
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function isAuthorized(
        address owner,
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        return
            spender != address(0) &&
            (owner == spender ||
                isApprovedForAll(owner, spender) ||
                getApproved(tokenId) == spender);
    }

    /**
     * @dev Checks if `spender` can operate on `tokenId`, assuming the provided `owner` is the actual owner.
     * Reverts if:
     * - `spender` does not have approval from `owner` for `tokenId`.
     * - `spender` does not have approval to manage all of `owner`'s assets.
     *
     * WARNING: This function assumes that `owner` is the actual owner of `tokenId` and does not verify this
     * assumption.
     */
    function checkAuthorized(
        address owner,
        address spender,
        uint256 tokenId
    ) internal view {
        if (!isAuthorized(owner, spender, tokenId)) {
            if (owner == address(0))
                revert IERC721Errors.ERC721NonexistentToken(tokenId);
            else
                revert IERC721Errors.ERC721InsufficientApproval(
                    spender,
                    tokenId
                );
        }
    }

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * NOTE: the value is limited to type(uint128).max. This protect against _balance overflow. It is unrealistic that
     * a uint256 would ever overflow from increments when these increments are bounded to uint128 values.
     *
     * WARNING: Increasing an account's balance using this function tends to be paired with an override of the
     * {_ownerOf} function to resolve the ownership of the corresponding tokens so that balances and ownership
     * remain consistent with one another.
     */
    function increaseBalance(address account, uint128 value) internal {
        unchecked {
            ERC721Storage.ERC721Slot().balances[account] += value;
        }
    }

    /**
     * @dev Unsafe write access to the balances, used by extensions that "mint" tokens using an {ownerOf} override.
     *
     * NOTE: the value is limited to type(uint128).max. This protect against _balance overflow. It is unrealistic that
     * a uint256 would ever overflow from increments when these increments are bounded to uint128 values.
     */
    function decreaseBalance(address account, uint128 value) internal {
        unchecked {
            ERC721Storage.ERC721Slot().balances[account] -= value;
        }
    }

    // ============================================== //
    //             ERC721 Enumerable Functions        //
    // ============================================== //

    function getTokensOfOwner(
        address owner
    ) internal view returns (uint256[] memory) {
        uint256 count = balanceOf(owner);
        uint256[] memory tokenIds = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(owner, i);
        }
        return tokenIds;
    }

    /**
     * @dev Returns the token ID at a given `index` of the tokens list of the requested `owner`.
     *
     * This function call must use less than 30 000 gas.
     */
    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) internal view returns (uint256) {
        if (index >= balanceOf(owner))
            revert IERC721EnumerableErrors.ERC721OutOfBoundsIndex(owner, index);
        return ERC721Storage.ERC721EnumerableSlot().ownedTokens[owner][index];
    }

    /**
     * @dev Returns the total number of tokens in existence.
     *
     * This function call must use less than 30 000 gas.
     */
    function totalSupply() internal view returns (uint256) {
        return ERC721Storage.ERC721EnumerableSlot().allTokens.length;
    }

    /**
     * @dev Returns the token ID at a given `index` of all the tokens in this contract.
     *
     * This function call must use less than 30 000 gas.
     */
    function tokenByIndex(uint256 index) internal view returns (uint256) {
        if (index >= totalSupply())
            revert IERC721EnumerableErrors.ERC721OutOfBoundsIndex(
                address(0),
                index
            );
        return ERC721Storage.ERC721EnumerableSlot().allTokens[index];
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function addTokenToOwnerEnumeration(address to, uint256 tokenId) internal {
        uint256 length = balanceOf(to) - 1;
        ERC721Storage.ERC721EnumerableSlot().ownedTokens[to][length] = tokenId;
        ERC721Storage.ERC721EnumerableSlot().ownedTokensIndex[tokenId] = length;
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function addTokenToAllTokensEnumeration(uint256 tokenId) internal {
        ERC721Storage.ERC721EnumerableSlot().allTokensIndex[
            tokenId
        ] = ERC721Storage.ERC721EnumerableSlot().allTokens.length;
        ERC721Storage.ERC721EnumerableSlot().allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the `_ownedTokensIndex` mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function removeTokenFromOwnerEnumeration(
        address from,
        uint256 tokenId
    ) internal {
        uint256 lastTokenIndex = balanceOf(from);
        uint256 tokenIndex = ERC721Storage
            .ERC721EnumerableSlot()
            .ownedTokensIndex[tokenId];
        mapping(uint256 index => uint256)
            storage _ownedTokensByOwner = ERC721Storage
                .ERC721EnumerableSlot()
                .ownedTokens[from];
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokensByOwner[lastTokenIndex];
            _ownedTokensByOwner[tokenIndex] = lastTokenId;
            ERC721Storage.ERC721EnumerableSlot().ownedTokensIndex[
                lastTokenId
            ] = tokenIndex;
        }
        delete ERC721Storage.ERC721EnumerableSlot().ownedTokensIndex[tokenId];
        delete _ownedTokensByOwner[lastTokenIndex];
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function removeTokenFromAllTokensEnumeration(uint256 tokenId) internal {
        uint256 lastTokenIndex = ERC721Storage
            .ERC721EnumerableSlot()
            .allTokens
            .length - 1;
        uint256 tokenIndex = ERC721Storage
            .ERC721EnumerableSlot()
            .allTokensIndex[tokenId];
        uint256 lastTokenId = ERC721Storage.ERC721EnumerableSlot().allTokens[
            lastTokenIndex
        ];
        ERC721Storage.ERC721EnumerableSlot().allTokens[
            tokenIndex
        ] = lastTokenId;
        ERC721Storage.ERC721EnumerableSlot().allTokensIndex[
            lastTokenId
        ] = tokenIndex;
        delete ERC721Storage.ERC721EnumerableSlot().allTokensIndex[tokenId];
        ERC721Storage.ERC721EnumerableSlot().allTokens.pop();
    }

    /**
     * @dev Transfers `tokenId` from its current owner to `to`, or alternatively mints (or burns) if the current owner
     * (or `to`) is the zero address. Returns the owner of the `tokenId` before the update.
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that
     * `auth` is either the owner of the token, or approved to operate on the token (by the owner).
     *
     * Emits a {Transfer} event.
     *
     * NOTE: If overriding this function in a way that tracks balances, see also {_increaseBalance}.
     */
    function update(
        address to,
        uint256 tokenId,
        address auth
    ) internal returns (address) {
        address previousOwner = _update(to, tokenId, auth);
        if (previousOwner == address(0)) {
            addTokenToAllTokensEnumeration(tokenId);
        } else if (previousOwner != to) {
            removeTokenFromOwnerEnumeration(previousOwner, tokenId);
        }
        if (to == address(0)) {
            removeTokenFromAllTokensEnumeration(tokenId);
        } else if (previousOwner != to) {
            addTokenToOwnerEnumeration(to, tokenId);
        }

        return previousOwner;
    }

    function _update(address to, uint256 tokenId, address auth) internal returns (address) {
        address from = ownerOf(tokenId);

        // Perform (optional) operator check
        if (auth != address(0)) {
            checkAuthorized(from, auth, tokenId);
        }

        // Execute the update
        if (from != address(0)) {
            // Clear approval. No need to re-authorize or emit the Approval event
            approve(address(0), tokenId, address(0), false);

            unchecked {
                decreaseBalance(from, 1);
            }
        }

        if (to != address(0)) {
            unchecked {
                increaseBalance(to, 1);
            }
        }

        ERC721Storage.ERC721Slot().owners[tokenId] = to;

        emit IERC721.Transfer(from, to, tokenId);

        return from;
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {_safeMint} whenever possible
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - `to` cannot be the zero address.
     *
     * Emits a {Transfer} event.
     */
    function mint(address to, uint256 tokenId) internal {
        if (to == address(0))
            revert IERC721Errors.ERC721InvalidReceiver(address(0));
        address previousOwner = update(to, tokenId, address(0));
        if (previousOwner != address(0))
            revert IERC721Errors.ERC721InvalidSender(address(0));
    }

    /**
     * @dev Mints `tokenId`, transfers it to `to` and checks for `to` acceptance.
     *
     * Requirements:
     *
     * - `tokenId` must not exist.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeMint(address to, uint256 tokenId) internal {
        safeMint(to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeMint-address-uint256-}[`_safeMint`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function safeMint(address to, uint256 tokenId, bytes memory data) internal {
        mint(to, tokenId);
        checkOnERC721Received(msg.sender, address(0), to, tokenId, data);
    }

    /**
     * @dev Destroys `tokenId`.
     * The approval is cleared when the token is burned.
     * This is an internal function that does not check if the sender is authorized to operate on the token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     *
     * Emits a {Transfer} event.
     */
    function burn(uint256 tokenId) internal {
        address previousOwner = update(address(0), tokenId, address(0));
        if (previousOwner == address(0))
            revert IERC721Errors.ERC721NonexistentToken(tokenId);
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address from, address to, uint256 tokenId) internal {
        if (to == address(0))
            revert IERC721Errors.ERC721InvalidReceiver(address(0));
        address previousOwner = update(to, tokenId, address(0));
        if (previousOwner == address(0))
            revert IERC721Errors.ERC721NonexistentToken(tokenId);
        else if (previousOwner != from)
            revert IERC721Errors.ERC721IncorrectOwner(
                from,
                tokenId,
                previousOwner
            );
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking that contract recipients
     * are aware of the ERC-721 standard to prevent tokens from being forever locked.
     *
     * `data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is like {safeTransferFrom} in the sense that it invokes
     * {IERC721Receiver-onERC721Received} on the receiver, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `tokenId` token must exist and be owned by `from`.
     * - `to` cannot be the zero address.
     * - `from` cannot be the zero address.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransfer(address from, address to, uint256 tokenId) internal {
        safeTransfer(from, to, tokenId, "");
    }

    /**
     * @dev Same as {xref-ERC721-_safeTransfer-address-address-uint256-}[`_safeTransfer`], with an additional `data` parameter which is
     * forwarded in {IERC721Receiver-onERC721Received} to contract recipients.
     */
    function safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        transfer(from, to, tokenId);
        checkOnERC721Received(msg.sender, from, to, tokenId, data);
    }
    // ======== Approve ========
    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * The `auth` argument is optional. If the value passed is non 0, then this function will check that `auth` is
     * either the owner of the token, or approved to operate on all tokens held by this owner.
     *
     * Emits an {Approval} event.
     *
     * Overrides to this logic should be done to the variant with an additional `bool emitEvent` argument.
     */
    function approve(address to, uint256 tokenId, address auth) internal {
        approve(to, tokenId, auth, true);
    }

    /**
     * @dev Variant of `_approve` with an optional flag to enable or disable the {Approval} event. The event is not
     * emitted in the context of transfers.
     */
    function approve(
        address to,
        uint256 tokenId,
        address auth,
        bool emitEvent
    ) internal {
        if (emitEvent || auth != address(0)) {
            address owner = requireOwned(tokenId);
            if (
                auth != address(0) &&
                owner != auth &&
                !isApprovedForAll(owner, auth)
            ) {
                revert IERC721Errors.ERC721InvalidApprover(auth);
            }
            if (emitEvent) emit IERC721.Approval(owner, to, tokenId);
        }
        ERC721Storage.ERC721Slot().tokenApprovals[tokenId] = to;
    }

    /**
     * @dev Approve `operator` to operate on all of `owner` tokens
     *
     * Requirements:
     * - operator can't be the address zero.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal {
        if (operator == address(0))
            revert IERC721Errors.ERC721InvalidOperator(operator);
        ERC721Storage.ERC721Slot().operatorApprovals[owner][
            operator
        ] = approved;
        emit IERC721.ApprovalForAll(owner, operator, approved);
    }
    function isApprovedForAll(
        address owner,
        address operator
    ) internal view returns (bool) {
        return ERC721Storage.ERC721Slot().operatorApprovals[owner][operator];
    }

    // ============================================== //
    //             ERC721URIStorage Functions         //
    // ============================================== //

    function tokenURI(uint256 tokenId) internal view returns (string memory) {
        // ERC721URIStorage優先
        requireOwned(tokenId);
        string memory _tokenURI = ERC721Storage
            .ERC721URIStorageSlot()
            .tokenURIs[tokenId];
        string memory base = baseURI();
        if (bytes(base).length == 0) return _tokenURI;
        if (bytes(_tokenURI).length > 0) return string.concat(base, _tokenURI);
        return "";
    }

    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Emits {IERC4906-MetadataUpdate}.
     */
    function setTokenURI(uint256 tokenId, string memory _tokenURI) internal {
        ERC721Storage.ERC721URIStorageSlot().tokenURIs[tokenId] = _tokenURI;
        emit IERC4906.MetadataUpdate(tokenId);
    }

    // ============================================== //
    //              ERC721 Utils Functions            //
    // ============================================== //

    function checkOnERC721Received(
        address operator,
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        ERC721Utils.checkOnERC721Received(operator, from, to, tokenId, data);
    }

    /**
     * @dev Reverts if the `tokenId` doesn't have a current owner (it hasn't been minted, or it has been burned).
     * Returns the owner.
     *
     * Overrides to ownership logic should be done to {_ownerOf}.
     */
    function requireOwned(uint256 tokenId) internal view returns (address) {
        address owner = ownerOf(tokenId);
        if (owner == address(0))
            revert IERC721Errors.ERC721NonexistentToken(tokenId);
        return owner;
    }
}
