// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @dev Interface for the Service Factory v0.1.0
 */
interface IServiceFactoryEvents {
    /**
     * @dev This event is emitted when a service is activated.
     * @param beacon The address of the beacon.
     * @param service The address of the activated service.
     */
    event ActivateService(
        address indexed beacon,
        address indexed service
    );
}
