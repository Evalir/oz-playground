// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "src/W1/Treasury.sol";
import "test/Helpers.sol";
import "test/mocks/ERC20.sol";

contract TreasuryPoC is Helpers {
    Treasury public t;
    MockERC20 public token;
    MockERC20 public unauthorizedToken;
    address public owner;

    function setUp() public {
        t = new Treasury();
        token = new MockERC20("Mock", "MCK");
        unauthorizedToken = new MockERC20("Mock2", "MCK2");
        token.mint(address(this), 1000);
        unauthorizedToken.mint(address(this), 1000);
        owner = account("owner");
    }

    /// @dev This test is the PoC for the bug found in the treasury contract,
    /// which is that the treasury does not save donations as they're written to a in-memory variable
    /// instead of to storage.
    function test_donationBug() public {
        // Approve token for transfer
        t.allow(address(token));
        // Owner donates 100 tokens.
        token.approve(address(t), 100);
        t.donate(address(token), 100);

        // expect the donations to NOT change,
        // even though the token is held by the treasury.
        assertEq(t.getDonation(address(this), address(token)), 0);
        assertEq(token.balanceOf(address(t)), 100);
        assertEq(token.balanceOf(address(this)), 900);
    }

    /// @dev This test is for a bug (or unexpected behavior) that was found in the treasury contract,
    /// which is that the treasury can receive unauthorized tokens. While not a problem in itself
    /// (even if the accounting worked correctly), depending on the contract usage, it could be
    /// considered a problem e.g if the contract could not legally hold OFAC restricted tokens
    /// Or somehow did some internal accounting based on the tokens it held (in case the token is allowed).
    function test_transferBug() public {
        // Approve token for transfer
        t.allow(address(token));
        // Owner donates 100 tokens.
        token.approve(address(t), 100);
        t.donate(address(token), 100);

        // This is not necessarily a bug, but rather a behavior to be aware of:
        // The treasury can receive unauthorized tokens; they just won't be assigned to the donor.
        // This can be done by just transfering to the treasury address.
        unauthorizedToken.transfer(address(t), 100);
        assertEq(t.getDonation(address(this), address(token)), 0);
        assertEq(t.allowlist(address(unauthorizedToken)), false);
        assertEq(unauthorizedToken.balanceOf(address(t)), 100);
        assertEq(unauthorizedToken.balanceOf(address(this)), 900);
    }
}
