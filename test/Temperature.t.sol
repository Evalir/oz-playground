// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/W1/Temperature.sol";
import "./Helpers.sol";

contract TemperatureTest is Helpers {
    event Betted(address indexed user, uint256 temperature);
    event TemperatureSet(uint256 temperature);

    Temperature public temp;
    address alice;
    address bob;
    address carol;

    function setUp() public {
        temp = new Temperature();
        alice = account("alice");
        bob = account("bob");
        carol = account("carol");
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.deal(carol, 10 ether);
    }

    function test_bettingFlow() public {
        // Alice bets (can you do something for me)
        vm.prank(alice);
        vm.expectEmit(true, false, false, false);
        emit Betted(alice, 21);
        temp.bet{value: 1 ether}(21);
        assertEq(temp.bets(alice), 21);

        // Bob bets
        vm.prank(bob);
        vm.expectEmit(true, false, false, false);
        emit Betted(bob, 21);
        temp.bet{value: 2 ether}(22);
        assertEq(temp.bets(bob), 22);

        // Carol bets the same as Alice
        vm.prank(carol);
        vm.expectEmit(true, false, false, false);
        emit Betted(carol, 21);
        temp.bet{value: 1 ether}(21);
        assertEq(temp.bets(carol), 21);

        // Carol tries to bet again (and fails)
        vm.prank(carol);
        vm.expectRevert("You already have a bet");
        temp.bet{value: 1 ether}(21);

        // Owner sets the temperature.
        temp.setTemperature(21);

        // Now, both Alice and Carol can cash out.
        // The first to do it gets the money.
        vm.prank(alice);
        temp.cashout();
        assert(address(temp).balance == 0);
        assert(address(alice).balance == 13 ether);
    }

    function test_fuzz_bettingFlow(uint256 bet1, uint256 bet2, uint256 bet3, uint256 temperature) public {
        bet1 = bound(bet1, 18, 30);
        bet2 = bound(bet2, 19, 27);
        bet3 = bound(bet3, 20, 26);
        temperature = bound(temperature, 17, 31);

        vm.prank(alice);
        vm.expectEmit(true, false, false, false);
        emit Betted(alice, bet1);
        temp.bet{value: 1 ether}(bet1);
        assertEq(temp.bets(alice), bet1);

        // Bob bets
        vm.prank(bob);
        vm.expectEmit(true, false, false, false);
        emit Betted(bob, bet2);
        temp.bet{value: 2 ether}(bet2);
        assertEq(temp.bets(bob), bet2);

        // Carol bets the same as Alice
        vm.prank(carol);
        vm.expectEmit(true, false, false, false);
        emit Betted(carol, bet3);
        temp.bet{value: 1 ether}(bet3);
        assertEq(temp.bets(carol), bet3);

        // Owner sets the temperature.
        temp.setTemperature(temperature);

        if (bet1 == temperature) {
            vm.prank(alice);
            temp.cashout();
            assert(address(temp).balance == 0);
            assert(address(alice).balance == 13 ether);
        } else if (bet2 == temperature) {
            vm.prank(bob);
            temp.cashout();
            assert(address(temp).balance == 0);
            assert(address(bob).balance == 12 ether);
        } else if (bet3 == temperature) {
            vm.prank(carol);
            temp.cashout();
            assert(address(temp).balance == 0);
            assert(address(carol).balance == 13 ether);
        }
    }
}
