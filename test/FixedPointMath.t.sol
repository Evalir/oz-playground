// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/W1/FixedPointMath.sol";
import "solmate/utils/FixedPointMathLib.sol";
import "./Helpers.sol";

contract FixedPointMathTest is Helpers {
    function setUp() public {}

    function test_diff_fuzz_Solmate(uint256 x, uint256 y) public view {
        x = bound(x, 1, uint256(1*1e38));
        y = bound(y, 1, uint256(1*1e38));
        uint a = FixedPointMath.mulWad(x, y);
        uint b = FixedPointMathLib.mulWadDown(x, y);
        assert(a == b);
    }
}