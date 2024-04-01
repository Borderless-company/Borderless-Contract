// SPDX-License-Identifier: Apache-2.0
pragma solidity =0.8.23;

import {Test, console} from "forge-std/Test.sol";
import {Sample} from "src/Samples/Sample.sol";

contract SampleTest is Test {
    Sample public sp;

    function setUp() public {
        sp = new Sample();
        sp.setNumber(0);
    }

    function test_Increment() public {
        sp.increment();
        assertEq(sp.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        sp.setNumber(x);
        assertEq(sp.number(), x);
    }
}
