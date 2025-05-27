// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity 0.8.28;

// storage
import {Storage as OwnableStorage} from "../storages/Storage.sol";

// libs
import {OwnableLib} from "../libs/OwnableLib.sol";

// interfaces
import {IOwnable} from "../interfaces/IOwnable.sol";

/**
 * @title Ownable
 * @notice Ownable is a contract that provides a basic access control mechanism.
 */
contract Ownable is IOwnable {
    // ============================================== //
    //                  INITIALIZE                    //
    // ============================================== //

    function initialize(address owner_) public virtual {
        require(owner_ != address(0), OwnableInvalidOwner(address(0)));
        OwnableStorage.OwnableSlot().owner = owner_;
    }

    // ============================================== //
    //                   MODIFIER                     //
    // ============================================== //

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        checkOwner();
        _;
    }

    // ============================================== //
    //             EXTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    /**
     * @dev Only the owner can renounce ownership.
     */
    function renounceOwnership() public virtual onlyOwner {
        OwnableLib.transferOwnership(address(0));
    }

    /**
     * @dev Only the owner can transfer ownership.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), OwnableInvalidOwner(newOwner));
        OwnableLib.transferOwnership(newOwner);
    }

    // ============================================== //
    //             EXTERNAL READ FUNCTIONS            //
    // ============================================== //

    function owner() public view virtual returns (address) {
        return OwnableStorage.OwnableSlot().owner;
    }

    // ============================================== //
    //             INTERNAL READ FUNCTIONS            //
    // ============================================== //

    function checkOwner() internal view virtual {
        require(owner() == msg.sender, OwnableUnauthorizedAccount(msg.sender));
    }
}
