// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {ITreasuryServiceBase} from "./interfaces/ITreasuryServiceBase.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title Test smart contract for Borderless.company service
contract TreasuryService is ITreasuryServiceBase, Initializable {
    // ============================================== //
    //                  Storage                       //
    // ============================================== //

    address private _admin;
    address private _company;

    // ============================================== //
    //                  Modifier                      //
    // ============================================== //

    modifier onlyService() {
        require(_validateCaller(), "Error: TreasuryService/Invalid-Caller");
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Error: TreasuryService/Only-Owner");
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

    function initialize(address admin_, address company_) external initializer {
        _admin = admin_;
        _company = company_;
    }

    // ============================================== //
    //             External Write Functions       //
    // ============================================== //

    function callAdmin() public view onlyAdmin returns (bool called_) {
        called_ = true;
    }

    // ============================================== //
    //             Internal Read Functions            //
    // ============================================== //

    function _validateCaller() internal view returns (bool called_) {
        if (msg.sender == _admin && msg.sender == _company) called_ = true;
    }
}
