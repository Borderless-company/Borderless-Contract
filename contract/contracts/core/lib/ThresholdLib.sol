// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title ThresholdLib
 * @notice ThresholdLib is a library that provides utility functions for thresholds.
 */
library ThresholdLib {
    // ============================================== //
    //                  ERRORS                        //
    // ============================================== //

    /**
     * @dev Error thrown when the denominator is not positive
     * @param denominator The denominator that is not positive
     */
    error DenominatorMustBePositive(uint256 denominator);

    // ============================================== //
    //                  FUNCTIONS                     //
    // ============================================== //

    /**
     * @dev Check if the value is greater than or equal to the threshold
     * @param threshold The threshold value
     * @param value The value to check
     * @return bool True if the value is greater than or equal to the threshold, false otherwise
     */
    function isThresholdReached(
        uint256 threshold,
        uint256 value
    ) internal pure returns (bool) {
        return value >= threshold;
    }

    /**
     * @dev Get two thirds of the value
     * @param value The value to get two thirds of
     * @return uint256 Two thirds of the value
     */
    function getTwoThirds(uint256 value) internal pure returns (uint256) {
        return (value * 2) / 3;
    }

    /**
     * @dev Get one fifth of the value
     * @param value The value to get one fifth of
     * @return uint256 One fifth of the value
     */
    function getOneFifth(uint256 value) internal pure returns (uint256) {
        return (value * 1) / 5;
    }

    /**
     * @dev Get the custom threshold
     * @param value The value to get the custom threshold of
     * @param numerator The numerator of the custom threshold
     * @param denominator The denominator of the custom threshold
     * @return uint256 The custom threshold
     */
    function getCustomThreshold(
        uint256 value,
        uint256 numerator,
        uint256 denominator
    ) internal pure returns (uint256) {
        require(denominator > 0, DenominatorMustBePositive(denominator));
        uint256 product = value * numerator;
        uint256 threshold = (product + denominator - 1) / denominator;
        return threshold == 0 ? 1 : threshold;
    }
}
