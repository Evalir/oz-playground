// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

contract WETHDonations {

    address weth = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    // how much everyone has donated to the contract
    mapping(address => uint) public donations;

    // when anyone can remove their donation 
    mapping(address => uint) public lockTimes;
    
    function _logDonation(address user, uint amount) internal {
        donations[user] += amount;
        lockTimes[user] = block.timestamp + 1 weeks;
    }

    // donate weth to the contract
    function donate(uint amount) external {
        IERC20(weth).transferFrom(msg.sender, address(this), amount);
        _logDonation(msg.sender, amount);
    }

    // donate weth to the contract with a signature
    // allows users to donate through other entities
    function donateWithPermit(address target, uint amount, uint deadline, uint8 v, bytes32 r, bytes32 s) external {
        IERC20Permit(weth).permit(target, address(this), value, deadline, v, r, s);
        IERC20(weth).transferFrom(target, address(this), amount);
        _logDonation(msg.sender, amount);
    }

    function addLockTime(uint seconds) public {
      lockTimes[msg.sender] += seconds;
    }
    
    function withdraw() public {
        require(balances[msg.sender] > 0);
        require(lockTimes[msg.sender] <= block.timestamp, "Cannot withdraw before lock is removed");
        balances[msg.sender] = 0;
        msg.sender.transfer(balances[msg.sender]);
    }

    /*
     * No additional functions in the contract. This contract will be deployed as a proxy contract
     * and additional functionality will be added in the future by the DAO.
     */

}