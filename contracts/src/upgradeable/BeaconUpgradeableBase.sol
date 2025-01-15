// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {IBeaconUpgradeableBase} from "./interfaces/IBeaconUpgradeableBase.sol";

// upgradeable
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

abstract contract BeaconUpgradeableBase is
    Initializable,
    IBeaconUpgradeableBase
{
    // ============================================== //
    //                    Storage                     //
    // ============================================== //

    /// @dev smart company number => beacon
    mapping(address => Beacon) public beacons;

    /// @dev beacon address => proxyId => proxyAddress
    mapping(address => mapping(uint256 => address)) private _proxies;

    // ============================================== //
    //                  Modifiers                     //
    // ============================================== //

    modifier invalidImplementation(address _implementation) {
        require(
            _implementation != address(0),
            InvalidImplementation(_implementation)
        );
        _;
    }

    modifier beaconNameNotEmpty(string calldata _name) {
        require(
            keccak256(bytes(_name)) != keccak256(bytes("")),
            InvalidName(_name)
        );
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

    function __BeaconUpgradeableBase_init() internal initializer {}

    // ============================================== //
    //            External Write Functions            //
    // ============================================== //

    function _createBeaconProxy(
        address _implementation,
        string calldata _name
    )
        internal
        invalidImplementation(_implementation)
        beaconNameNotEmpty(_name)
        returns (address)
    {
        UpgradeableBeacon _proxy = new UpgradeableBeacon(
            _implementation,
            msg.sender
        );
        beacons[_implementation] = Beacon({
            name: _name,
            beacon: address(_proxy),
            isOnline: true,
            proxyCount: 0
        });
        emit ProxyCreated(address(_proxy), _name);
        return address(_proxy);
    }

    function _updateBeaconName(
        address _implementation,
        string calldata _name
    )
        internal
        invalidImplementation(_implementation)
        beaconNameNotEmpty(_name)
        returns (Beacon memory _beacon)
    {
        _beacon = beacons[_implementation];
        _beacon.name = _name;
        emit BeaconNameUpdated(_implementation, _name);
        return _beacon;
    }

    function _changeBeaconOnline(
        address _implementation,
        bool _isOnline
    ) internal returns (bool) {
        require(
            beacons[_implementation].isOnline != _isOnline,
            BeaconAlreadyOnlineOrOffline(_implementation)
        );
        beacons[_implementation].isOnline = _isOnline;
        if (_isOnline) {
            emit BeaconOnline(_implementation);
        } else {
            emit BeaconOffline(_implementation);
        }
        return _isOnline;
    }

    function _addProxy(
        address _implementation,
        address _proxyAddress
    ) internal {
        beacons[_implementation].proxyCount++;
        _proxies[_proxyAddress][
            beacons[_implementation].proxyCount
        ] = _proxyAddress;
        emit ProxyAdded(_proxyAddress, beacons[_implementation].name);
    }
}
