// SPDX-License-Identifier: GPL-3.0
pragma solidity =0.8.24;

import {ILETSService} from "src/interfaces/Services/LETSService/ILETSService.sol";
import {EventLETSService} from "src/interfaces/Services/LETSService/EventLETSService.sol";
import {ErrorLETSService} from "src/interfaces/Services/LETSService/ErrorLETSService.sol";
import {NonFungibleTokenTYPE721} from "src/Services/TokenStandards/NonFungibleTokenTYPE721.sol";

/// @title Test smart contract for Borderless.company service
contract LETSService is ILETSService, EventLETSService, ErrorLETSService {
    address private _admin;
    address private _company;
    uint256 private _lastIndex721;
    mapping(uint256 index_ => TokenInfo info_) private _standard721tokens;

    constructor(address admin_, address company_) {
        _admin = admin_;
        _company = company_;
    }

    function activateStandard721Token(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        bool sbt_
    ) external override onlyAdmin returns (bool success_) {
        if (bytes(name_).length == 0 || bytes(symbol_).length == 0)
            revert InvalidParam(msg.sender, name_, symbol_, baseURI_);

        success_ = _activateStandard721Token(name_, symbol_, baseURI_, sbt_);
    }

    function _activateStandard721Token(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        bool sbt_
    ) internal returns (bool success_) {
        address token_ = address(
            new NonFungibleTokenTYPE721(_admin, name_, symbol_, baseURI_, sbt_)
        );

        emit NewNonFungibleToken721(token_, symbol_, name_, sbt_);

        _lastIndex721++;
        _standard721tokens[_lastIndex721] = TokenInfo(
            token_,
            name_,
            symbol_,
            block.timestamp,
            sbt_
        );

        success_ = true;
    }

    // TODO: activateStandard20Tokenの作成

    function getLastIndexStandard721Token()
        external
        view
        returns (uint256 index_)
    {
        index_ = _lastIndex721;
    }

    function getInfoStandard721token(
        uint256 index_
    )
        external
        view
        returns (
            address token_,
            string memory name_,
            string memory symbol_,
            bool sbt_
        )
    {
        TokenInfo memory _info;
        if (index_ == 0 || index_ > _lastIndex721) revert InvalidIndex(index_);

        _info = _standard721tokens[index_];
        (token_, name_, symbol_, sbt_) = (
            _info.token_,
            _info.name_,
            _info.symbol_,
            _info.sbt_
        );
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Error: LETSService/Only-Owner");
        _;
    }

    modifier onlyService(address admin_) {
        require(_validateCaller(admin_), "Error: LETSService/Invalid-Caller");
        _;
    }

    function _validateCaller(
        address admin_
    ) internal view returns (bool called_) {
        if (admin_ == _admin && msg.sender == _company) called_ = true;
    }
}
