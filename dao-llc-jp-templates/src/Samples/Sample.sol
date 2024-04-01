// SPDX-License-Identifier: Apache-2.0
pragma solidity =0.8.24;

contract Sample {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
