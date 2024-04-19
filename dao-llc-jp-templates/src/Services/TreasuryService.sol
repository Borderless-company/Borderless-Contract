// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {ITreasuryService} from "src/interfaces/Services/TreasuryService/ITreasuryService.sol";

/// @title Test smart contract for Borderless.company service
contract TreasuryService is ITreasuryService {
    address private _admin;
    address private _company;

    constructor(address admin_, address company_) {
        _admin = admin_;
        _company = company_;
    }

    function callAdmin() public view onlyOwner returns (bool called_) {
        called_ = true;
    }

    modifier onlyService() {
        require(_validateCaller(), "Error: TreasuryService/Invalid-Caller");
        _;
    }

    modifier onlyOwner(){
        require(msg.sender == _admin, "Error: TreasuryService/Only-Owner");
        _;
    }

    function _validateCaller() internal view returns (bool called_) {
        if(msg.sender == _admin && msg.sender == _company) called_ = true;
    }
}
