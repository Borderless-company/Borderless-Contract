// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {ITokenService} from "./interfaces/TokenService/ITokenService.sol";
import {EventTokenService} from "./interfaces/TokenService/EventTokenService.sol";
import {ErrorTokenService} from "./interfaces/TokenService/ErrorTokenService.sol";
import {NonFungibleTokenTYPE721} from "./TokenStandards/NonFungibleTokenTYPE721.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/// @title Test smart contract for Borderless.company service
contract TokenService is
    ITokenService,
    EventTokenService,
    ErrorTokenService,
    Initializable
{
    // ============================================== //
    //                  Storage                      //
    // ============================================== //

    address private _admin;
    address private _company;
    uint256 private _lastIndex721;
    mapping(uint256 index_ => TokenInfo info_) private _standard721tokens;

    // ============================================== //
    //                  Modifier                      //
    // ============================================== //

    modifier onlyAdmin() {
        require(msg.sender == _admin, "Error: TokenService/Only-Owner");
        _;
    }

    modifier onlyService(address admin_) {
        require(_validateCaller(admin_), "Error: TokenService/Invalid-Caller");
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
    //             External Write Functions           //
    // ============================================== //

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

    // ============================================== //
    //             Internal Write Functions           //
    // ============================================== //

    function _activateStandard721Token(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        bool sbt_
    ) internal returns (bool success_) {
        address token_ = address(
            new NonFungibleTokenTYPE721()
        );
        NonFungibleTokenTYPE721(token_).initialize(_admin, name_, symbol_, baseURI_, sbt_);

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

    // ============================================== //
    //             External Read Functions            //
    // ============================================== //

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

    // ============================================== //
    //             Internal Read Functions           //
    // ============================================== //

    function _validateCaller(
        address admin_
    ) internal view returns (bool called_) {
        if (admin_ == _admin && msg.sender == _company) called_ = true;
    }
}
