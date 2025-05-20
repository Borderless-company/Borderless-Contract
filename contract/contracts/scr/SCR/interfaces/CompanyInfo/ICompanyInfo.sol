// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import {ICompanyInfoFunctions} from "./ICompanyInfoFunctions.sol";
import {ICompanyInfoEvents} from "./ICompanyInfoEvents.sol";
import {ICompanyInfoStructs} from "./ICompanyInfoStructs.sol";
import {ICompanyInfoErrors} from "./ICompanyInfoErrors.sol";

interface ICompanyInfo is
    ICompanyInfoFunctions,
    ICompanyInfoEvents,
    ICompanyInfoStructs,
    ICompanyInfoErrors
{}
