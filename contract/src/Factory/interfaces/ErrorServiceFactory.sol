// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

import {IServiceFactory} from "./IServiceFactory.sol";

/// @title Error interface
interface ErrorServiceFactory {
    /**
     * @dev Error informing that the caller is not the Smart Company Register Contract.
     * @param caller The address of the caller.
     */
    error OnlySTR(address caller);

    /**
     * @dev This error is emitted when an invalid address is provided.
     * @param _account The invalid address.
     */
    error InvalidAddress(address _account);

    /**
     * @dev Error informing that the service has not been activated.
     * @param account_ The address of the account that caused the error.
     * @param company_ The address of the company that caused the error.
     * @param serviceImplementation_ The address of the service implementation that caused the error.
     */
    error DoNotActivateService(address account_, address company_, address serviceImplementation_);

    /**
     * @dev Error informing that the service has not been set.
     * @param _service The address of the service.
     */
    error DoNotSetService(address _service);
}
