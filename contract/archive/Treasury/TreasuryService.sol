// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

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
    //                  MODIFIER                      //
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
    //             EXTERNAL WRITE FUNCTIONS       //
    // ============================================== //

    function callAdmin() public view onlyAdmin returns (bool called_) {
        called_ = true;
    }

    // ============================================== //
    //             INTERNAL READ FUNCTIONS            //
    // ============================================== //

    function _validateCaller() internal view returns (bool called_) {
        if (msg.sender == _admin && msg.sender == _company) called_ = true;
    }
}
