// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title ThresholdLib
 * @notice ThresholdLib is a library that provides utility functions for thresholds.
 */
library ThresholdLib {
    /**
     * @dev Check if the value is greater than or equal to the threshold
     * @param threshold_ The threshold value
     * @param value_ The value to check
     * @return bool True if the value is greater than or equal to the threshold, false otherwise
     */
    function isThresholdReached(
        uint256 threshold_,
        uint256 value_
    ) internal pure returns (bool) {
        return value_ >= threshold_;
    }

    /**
     * @dev Get two thirds of the value
     * @param _value The value to get two thirds of
     * @return uint256 Two thirds of the value
     */
    function getTwoThirds(uint256 _value) internal pure returns (uint256) {
        return (_value * 2) / 3;
    }

    /**
     * @dev Get one fifth of the value
     * @param _value The value to get one fifth of
     * @return uint256 One fifth of the value
     */
    function getOneFifth(uint256 _value) internal pure returns (uint256) {
        return (_value * 1) / 5;
    }

    /**
     * @dev Get the custom threshold
     * @param _value The value to get the custom threshold of
     * @param _numerator The numerator of the custom threshold
     * @param _denominator The denominator of the custom threshold
     * @return uint256 The custom threshold
     */
    function getCustomThreshold(
        uint256 _value,
        uint256 _numerator,
        uint256 _denominator
    ) internal pure returns (uint256) {
        return (_value * _numerator) / _denominator;
    }
}
