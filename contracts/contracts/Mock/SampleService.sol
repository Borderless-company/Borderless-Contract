// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/// @title Test sample smart contract for Borderless.company service
contract SampleService {
    address private _admin;
    address private _company;

    constructor(address admin_, address company_) {
        _admin = admin_;
        _company = company_;
    }

    function callAdmin() public view onlyService returns (bool called_) {
        called_ = true;
    }

    modifier onlyService() {
        require(_validateCaller(), "Error: SampleService/Invalid-Caller");
        _;
    }

    function _validateCaller() internal view returns (bool called_) {
        if (msg.sender == _admin && msg.sender == _company) called_ = true;
    }
}
