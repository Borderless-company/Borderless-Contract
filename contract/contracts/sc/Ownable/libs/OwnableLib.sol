// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity 0.8.28;

// storage
import {Storage as OwnableStorage} from "../storages/Storage.sol";

// interfaces
import {IOwnableErrors} from "../interfaces/IOwnableErrors.sol";
import {IOwnableEvents} from "../interfaces/IOwnableEvents.sol";

/**
 * @dev Ownable library.
 */
library OwnableLib {
    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view {
        if (OwnableStorage.OwnableSlot().owner != msg.sender) {
            revert IOwnableErrors.OwnableUnauthorizedAccount(msg.sender);
        }
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal {
        address oldOwner = OwnableStorage.OwnableSlot().owner;
        OwnableStorage.OwnableSlot().owner = newOwner;
        emit IOwnableEvents.OwnershipTransferred(oldOwner, newOwner);
    }
}