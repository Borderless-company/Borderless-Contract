// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {IGovernanceService} from "src/interfaces/Services/GovernanceService/IGovernanceService.sol";

/// @title Test smart contract for Borderless.company service
contract GovernanceService is IGovernanceService {
    address private _admin;
    address private _company;

    constructor(address admin_, address company_) {
        _admin = admin_;
        _company = company_;
    }

    function callAdmin() public view onlyOwner returns (bool called_) {
        called_ = true;
    }

    modifier onlyOwner(){
        require(msg.sender == _admin, "Error: GovernanceService/Only-Owner");
        _;
    }

    modifier onlyService() {
        require(_validateCaller(), "Error: GovernanceService/Invalid-Caller");
        _;
    }

    function _validateCaller() internal view returns (bool called_) {
        if(msg.sender == _admin && msg.sender == _company) called_ = true;
    }
}
