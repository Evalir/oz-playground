// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Treasury
 * @dev This contract accepts donations in ERC-20 tokens. Only tokens that have been added to the
 * allowlist can be donated. The allowlist can only be modified by the contract owner which is
 * controlled by the DAO. All tokens added to the allowlist are highly liquid and trusted tokens
 * which have been properly vetted by industry professionals. All tokens follow the ERC-20
 * specification.
 */
contract Treasury is Ownable {
    using SafeERC20 for ERC20;

    struct Donation {
        uint256 amount; // Total amount of the token that has been donated
        uint256 numDonations; // The total number of donations the account has made
    }

    // Registry that tracks donations by token and donor
    mapping(address => mapping(address => Donation)) public donations;

    // Allowlist that the owner can add tokens to. Only tokens on the allowlist can be donated.
    mapping(address => bool) public allowlist;

    /**
     * @dev Transfers _amount of _token from the callers account to this contract and records
     * the donation.
     * @param _token The ERC-20 token that is being donated.
     * @param _amount Amount of _token that is being donated.
     */
    function donate(address _token, uint256 _amount) external {
        // Only tokens on the allowlist can be donated
        require(allowlist[_token], "Invalid token");

        // Transfer the appropriate amount of tokens from msg.sender using safeTransferFrom
        // to ensure the call reverts if the transfer fails.
        ERC20(_token).safeTransferFrom(msg.sender, address(this), _amount);

        // Update the registry with the new donation
        _updateDonor(donations[_token][msg.sender], _amount);
    }

    function allow(address _token) external onlyOwner {
        allowlist[_token] = true;
    }

    /**
     * @dev Get the amount that _account has donated in _token.
     * @param _account Account address
     * @param _token ERC-20 token
     */
    function getDonation(address _account, address _token) public view returns (uint256) {
        return donations[_account][_token].amount;
    }

    // Update the donor registry
    function _updateDonor(Donation memory donation, uint256 _amount) private {
        unchecked {
            donation.amount += _amount;
            donation.numDonations++;
        }
    }

    /* Additional functions that have been properly implemented and are bug-free. */
}
