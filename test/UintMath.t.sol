// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/W4/UintMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./Helpers.sol";

contract Log2Test is Helpers {
    function setUp() public {}

    function test_diff_fuzz_OZ(uint256 x) public pure {
        uint256 a = UintMath.log2(x);
        uint256 b = Math.log2(x);
        assert(a == b);
    }
}
