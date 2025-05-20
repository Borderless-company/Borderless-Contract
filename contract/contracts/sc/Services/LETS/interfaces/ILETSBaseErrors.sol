// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

interface ILETSBaseErrors {
    /**
     * @dev not lets sale error
     * @param caller caller address
     */
    error NotLetsSale(address caller);

    /**
     * @dev not governance error
     * @param caller caller address
     */
    error NotGovernance(address caller);

    /**
     * @dev not transferable error
     */
    error NotTransferable();
}
