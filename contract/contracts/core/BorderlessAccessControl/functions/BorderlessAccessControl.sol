// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

// lib
import {BorderlessAccessControlLib} from "../libs/BorderlessAccessControlLib.sol";
import {BorderlessAccessControlInitializeLib} from "../libs/BorderlessAccessControlInitializeLib.sol";

// interfaces
import {IBorderlessAccessControl} from "../interfaces/IBorderlessAccessControl.sol";

// OpenZeppelin
import {IAccessControl} from "@openzeppelin/contracts/access/IAccessControl.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

/**
 * @title BorderlessAccessControl
 * @notice BorderlessAccessControl is a contract that provides access control for the Borderless protocol.
 */
contract BorderlessAccessControl is
    IAccessControl,
    ERC165,
    IBorderlessAccessControl
{
    // ============================================== //
    //                  MODIFIERS                     //
    // ============================================== //

    /**
     * @dev MODIFIER that checks that an account has a specific role. Reverts
     * with an {AccessControlUnauthorizedAccount} error including the required role.
     */
    modifier onlyRole(bytes32 role) {
        BorderlessAccessControlLib.checkRole(role);
        _;
    }

    // ============================================== //
    //                  INITIALIZE                    //
    // ============================================== //

    function initialize(address dictionary) public {
        BorderlessAccessControlInitializeLib.initialize(dictionary);
    }

    // ============================================== //
    //             EXTERNAL WRITE FUNCTIONS           //
    // ============================================== //

    /**
     * @dev Only the admin role can grant a role to an account.
     */
    function grantRole(
        bytes32 role,
        address account
    )
        public
        virtual
        override(IAccessControl, IBorderlessAccessControl)
        onlyRole(BorderlessAccessControlLib.getRoleAdmin(role))
    {
        BorderlessAccessControlLib.grantRole(role, account);
    }

    /**
     * @dev Only the admin role can revoke a role from an account.
     */
    function revokeRole(
        bytes32 role,
        address account
    )
        public
        virtual
        override(IAccessControl, IBorderlessAccessControl)
        onlyRole(BorderlessAccessControlLib.getRoleAdmin(role))
    {
        BorderlessAccessControlLib.revokeRole(role, account);
    }

    /**
     * @dev Only the admin role can renounce a role.
     */
    function renounceRole(
        bytes32 role,
        address callerConfirmation
    ) public virtual override(IAccessControl, IBorderlessAccessControl) {
        if (callerConfirmation != msg.sender) {
            revert AccessControlBadConfirmation();
        }

        BorderlessAccessControlLib.revokeRole(role, callerConfirmation);
    }

    function setAdminRole(
        bytes32 role,
        bytes32 adminRole
    ) public virtual override {
        BorderlessAccessControlLib.setRoleAdmin(role, adminRole);
    }

    // ============================================== //
    //             EXTERNAL READ FUNCTIONS            //
    // ============================================== //

    function DEFAULT_ADMIN_ROLE() public pure override returns (bytes32) {
        return BorderlessAccessControlLib.DEFAULT_ADMIN_ROLE();
    }

    function FOUNDER_ROLE() public pure override returns (bytes32) {
        return BorderlessAccessControlLib.FOUNDER_ROLE();
    }

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC165, IBorderlessAccessControl)
        returns (bool)
    {
        return
            interfaceId == type(IAccessControl).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function getRoleAdmin(
        bytes32 role
    )
        public
        view
        override(IAccessControl, IBorderlessAccessControl)
        returns (bytes32)
    {
        return BorderlessAccessControlLib.getRoleAdmin(role);
    }

    function hasRole(
        bytes32 role,
        address account
    )
        public
        view
        override(IAccessControl, IBorderlessAccessControl)
        returns (bool)
    {
        return BorderlessAccessControlLib.hasRole(role, account);
    }
}
