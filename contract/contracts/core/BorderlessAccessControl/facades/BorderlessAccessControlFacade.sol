// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// interfaces
import {IBorderlessAccessControl} from "../interfaces/IBorderlessAccessControl.sol";

/**
 * @title BorderlessAccessControlFacade
 * @notice Proxy contract for the BorderlessAccessControl contract.
 */
contract BorderlessAccessControlFacade is IBorderlessAccessControl {
    // ============================================== //
    //             EXTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    function grantRole(bytes32 role, address account) external override {}

    function revokeRole(bytes32 role, address account) external override {}

    function renounceRole(
        bytes32 role,
        address callerConfirmation
    ) external override {}

    function setAdminRole(bytes32 role, bytes32 adminRole) external override {}

    // ============================================== //
    //             EXTERNAL READ FUNCTIONS            //
    // ============================================== //

    function DEFAULT_ADMIN_ROLE() external view override returns (bytes32) {}

    function FOUNDER_ROLE() external view override returns (bytes32) {}

    function supportsInterface(
        bytes4 interfaceId
    ) external view virtual override returns (bool) {}

    function getRoleAdmin(
        bytes32 role
    ) external view override returns (bytes32) {}

    function hasRole(
        bytes32 role,
        address account
    ) external view override returns (bool) {}
}
