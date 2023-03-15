// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract FixedPointMath {
    function mulWad(uint256 x, uint256 y) public pure returns (uint256) {
        return x * y / 1e18;
    }

    function divWad(uint256 x, uint256 y) public pure returns (uint256) {
        return x * 1e18 / y;
    }
}