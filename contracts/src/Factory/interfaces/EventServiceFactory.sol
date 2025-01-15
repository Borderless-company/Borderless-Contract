// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {IServiceFactory} from "./IServiceFactory.sol";

/// @title Event interface
interface EventServiceFactory {
    /**
     * @dev This event is emitted when a new service is added.
     * @param _service The address of the added service.
     * @param _serviceName The name of the service.
     * @param _serviceType The type of the service.
     */
    event NewService(
        address indexed _service,
        string indexed _serviceName,
        IServiceFactory.ServiceType _serviceType
    );

    /**
     * @dev This event is emitted when the status of a service is updated.
     * @param _service The address of the updated service.
     * @param _serviceName The name of the service.
     * @param _serviceType The type of the service.
     * @param _isOnline The online status of the service.
     */
    event UpdateService(
        address indexed _service,
        string indexed _serviceName,
        IServiceFactory.ServiceType _serviceType,
        bool _isOnline
    );

    /**
     * @dev This event is emitted when a borderless service is activated.
     * @param admin_ The address of the admin that activated the service.
     * @param service The address of the activated service.
     * @param serviceName The name of the activated service.
     */
    event CreateService(
        address indexed admin_,
        address indexed service,
        string indexed serviceName
    );

    /**
     * @dev This event is emitted when a service is activated.
     * @param serviceImplementation The address of the service implementation.
     * @param service The address of the activated service.
     */
    event ActivateService(
        address indexed serviceImplementation,
        address indexed service
    );
}
