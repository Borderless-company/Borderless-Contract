// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @dev Service type enum
 * @param NON Non-service
 * @param AOI Aoi service
 * @param GOVERNANCE Governance service
 * @param LETS_EXE Legal Embedded Token Service for Execution
 * @param LETS_NON_EXE Legal Embedded Token Service for Non-Execution
 * @param LETS_SALE Legal Embedded Token Sale service
 * @param TREASURY Treasury service
 */
enum ServiceType {
    NON,
    AOI,
    GOVERNANCE,
    LETS_EXE,
    LETS_NON_EXE,
    LETS_SALE,
    TREASURY
}

enum ContractType {
    SCR,
    SERVICE_FACTORY
}
