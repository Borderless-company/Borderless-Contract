// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { ServiceType } from "./ITypes.sol";

interface ISCTInitialize {
	function initialize(
		address founder,
		address scr,
		bytes calldata
	) external;

	function registerService(
		ServiceType[] calldata serviceTypes,
        address[] calldata services
	) external;
}