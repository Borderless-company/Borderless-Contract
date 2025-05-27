// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

/**
 * @title ArrayLib
 * @notice ArrayLib is a library that provides utility functions for arrays.
 */
library ArrayLib {
    function removeAndCompact(
        string[] storage array,
        uint256 index
    ) internal returns (string[] memory) {
        require(index < array.length, "Index out of bounds");

        uint256 length = array.length;

        for (uint256 i = index; i < length - 1; i++) {
            array[i] = array[i + 1];
        }

        array.pop();
        return array;
    }
}
