// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

abstract contract BeaconUpgradeableBase is Initializable, OwnableUpgradeable {
    // ============================================== //
    //                  Events                        //
    // ============================================== //
    event ProxyCreated(
        uint256 indexed instanceId,
        address indexed proxyAddress
    );

    // ============================================== //
    //                  State Variables               //
    // ============================================== //
    UpgradeableBeacon public beacon;

    // proxyId => proxyAddress
    mapping(uint256 => address) private proxies;

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

    function __BeaconUpgradeableBase_init(
        address _implementation
    ) internal initializer {
        beacon = new UpgradeableBeacon(_implementation, msg.sender);
    }

    // ============================================== //
    //            External Write Functions            //
    // ============================================== //

    /// @notice プロキシを作成
    /// @param _proxyId プロキシID
    /// @param _data データ
    /// @return プロキシアドレス
    function createProxy(
        uint256 _proxyId,
        bytes memory _data
    ) external onlyOwner returns (address) {
        BeaconProxy proxy = new BeaconProxy(address(beacon), _data);
        proxies[_proxyId] = address(proxy);
        emit ProxyCreated(_proxyId, address(proxy));
        return address(proxy);
    }

    // ============================================== //
    //            External View Functions             //
    // ============================================== //

    /// @notice プロキシIDからプロキシアドレスを取得
    /// @param _proxyId プロキシID
    /// @return プロキシアドレス
    function getProxyAddress(uint256 _proxyId) external view returns (address) {
        return proxies[_proxyId];
    }

    /// @notice ビーコンアドレスを取得
    /// @return ビーコンアドレス
    function getBeacon() public view returns (address) {
        return address(beacon);
    }

    /// @notice 実装アドレスを取得
    /// @return 実装アドレス
    function getImplementation() public view returns (address) {
        return beacon.implementation();
    }
}
