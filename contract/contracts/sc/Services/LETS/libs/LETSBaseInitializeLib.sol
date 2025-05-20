// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// storage
import {Storage as LETSBaseStorage} from "../storages/Storage.sol";
import {Storage as ERC721Storage} from "../../../ERC721/storages/Storage.sol";
import {Storage as OwnableStorage} from "../../../Ownable/storages/Storage.sol";

// interfaces
import {IErrors} from "../../../../core/utils/IErrors.sol";
import {IOwnableErrors} from "../../../Ownable/interfaces/IOwnableErrors.sol";

library LETSBaseInitializeLib {
    function initialize(address founder, bytes calldata params) internal {
        (
            string memory name,
            string memory symbol,
            string memory baseURI,
            string memory extension
        ) = abi.decode(params, (string, string, string, string));
        require(
            bytes(name).length > 0 &&
                bytes(symbol).length > 0 &&
                bytes(baseURI).length > 0 &&
                bytes(extension).length > 0,
            IErrors.InvalidParam(bytes32(params))
        );
        require(
            founder != address(0),
            IOwnableErrors.OwnableInvalidOwner(address(0))
        );

        ERC721Storage.ERC721Slot().name = name;
        ERC721Storage.ERC721Slot().symbol = symbol;
        LETSBaseStorage.LETSBaseSlot().baseURI = baseURI;
        LETSBaseStorage.LETSBaseSlot().extension = extension;
        OwnableStorage.OwnableSlot().owner = founder;
    }
}
