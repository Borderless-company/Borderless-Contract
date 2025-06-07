// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// lib
import {Storage} from "../storages/Storage.sol";
import {BorderlessAccessControlLib} from "../../../core/BorderlessAccessControl/libs/BorderlessAccessControlLib.sol";

// interface
import {IPriceManager} from "../interfaces/IPriceManager.sol";
import {IPriceManagerErrors} from "../interfaces/IPriceManagerErrors.sol";
import {Constants} from "../../../core/lib/Constants.sol";

// OpenZeppelin
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";

/**
 * @title PriceManager
 * @notice This contract is used to manage the price of the LETS
 */
contract PriceManager is IPriceManager {
    function setPrice(uint256 price) external {
        require(price > 0, IPriceManagerErrors.PriceMustBeGreaterThanZero());
        BorderlessAccessControlLib.onlyRole(
            Constants.DEFAULT_ADMIN_ROLE,
            msg.sender
        );
        Storage.priceManagerSlot().price = price;
    }

    function getPrice() external view returns (uint256) {
        return Storage.priceManagerSlot().price;
    }
}
