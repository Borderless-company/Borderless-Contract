// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface IBorderlessAccessControl {
    // ============================================== //
    //             EXTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    /**
     * @notice Grants a role to an account.
     * @param role The role to grant.
     * @param account The account to grant the role to.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @notice Revokes a role from an account.
     * @param role The role to revoke.
     * @param account The account to revoke the role from.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @notice Renounces a role.
     * @param role The role to renounce.
     * @param callerConfirmation The address of the caller confirmation.
     */
    function renounceRole(bytes32 role, address callerConfirmation) external;

    /**
     * @notice Sets the admin role for a given role.
     * @param role The role to set the admin role for.
     * @param adminRole The admin role to set.
     */
    function setAdminRole(
        bytes32 role,
        bytes32 adminRole
    ) external;

    // ============================================== //
    //             EXTERNAL READ FUNCTIONS            //
    // ============================================== //

    /**
     * @notice Returns the default admin role.
     * @return The default admin role.
     */
    function DEFAULT_ADMIN_ROLE() external view returns (bytes32);

    /**
     * @notice Returns the founder role.
     * @return The founder role.
     */
    function FOUNDER_ROLE() external view returns (bytes32);

    /**
     * @notice Returns whether the contract supports the given interface.
     * @param interfaceId The interface identifier.
     * @return True if the contract supports the interface, false otherwise.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) external view returns (bool);

    /**
     * @notice Returns the admin role for a given role.
     * @param role The role to get the admin role for.
     * @return The admin role for the given role.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @notice Returns whether an account has a given role.
     * @param role The role to check.
     * @param account The account to check.
     * @return True if the account has the role, false otherwise.
     */
    function hasRole(
        bytes32 role,
        address account
    ) external view returns (bool);
}