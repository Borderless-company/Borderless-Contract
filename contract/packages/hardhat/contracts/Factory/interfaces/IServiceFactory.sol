// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.27;

interface IServiceFactory {
    // ============================================== //
    //                  Enum Types                    //
    // ============================================== //
    enum ServiceType {
        NON,
        GOVERNANCE,
        LETS_EXE,
        LETS_NON_EXE,
        TREASURY
    }

    // ============================================== //
    //             External Write Functions           //
    // ============================================== //

    /**
     * @dev Set new service contract address
     * @param _serviceImplementation Service implementation address
     * @param _serviceType Service type
     */
    function setService(
        address _serviceImplementation,
        string calldata _serviceName,
        ServiceType _serviceType
    ) external;

    /**
     * @dev Update service info
     * @param _serviceImplementation Service implementation address
     * @param _serviceType Service type
     */
    function updateServiceName(
        address _serviceImplementation,
        string calldata _serviceName,
        ServiceType _serviceType
    ) external;

    /**
     * @dev Change service offline
     * @param _serviceImplementation Service implementation address
     * @param _isOnline Service online status
     */
    function changeServiceOnline(
        address _serviceImplementation,
        bool _isOnline
    ) external;

    /**
     * @dev Activate service
     * @param _admin Admin address
     * @param _company Company address
     * @param _serviceImplementation Service implementation address
     * @param _extraParams Extra params
     * @return service_ Service address
     */
    function activate(
        address _admin,
        address _company,
        address _serviceImplementation,
        bytes memory _extraParams,
        ServiceType _serviceType
    ) external returns (address service_);

    // ============================================== //
    //             External Read Functions            //
    // ============================================== //

    /**
     * @dev Get service info
     * @param _serviceImplementation Service implementation address
     * @return _serviceName Service name
     * @return _service Service contract address
     * @return _online Service online status
     * @return _proxyCount Proxy count
     * @return _serviceType Service type
     */
    function getService(
        address _serviceImplementation
    )
        external
        returns (
            string memory _serviceName,
            address _service,
            bool _online,
            uint256 _proxyCount,
            uint256 _serviceType
        );

    /**
     * @dev Set SCR address
     * @param _scr SCR address
     */
    function setSCR(address _scr) external;
}
