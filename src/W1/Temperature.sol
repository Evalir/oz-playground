// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/// @title Simple, very unsafe temperature betting contract
/// @notice Please do not use this in production.
/// Enables users to bet on the temperature that will be set by the contract owner at a point in time.
/// Users can bet whatever they want (so the optimal strategy is to bet as little as possible).
/// Whoever gets the temperature right gets to cash out first.
/// If several people get the bet right, have fun frontrunning them for the prize :).
/// The `cashout_unsafe` function is vulnerable to reentrancy.
contract TemperatureBetting {
    uint256 public temperature;
    address public owner;
    mapping(address => uint256) public bets;

    event Betted(address indexed user, uint256 temperature);
    event TemperatureSet(uint256 temperature);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function bet(uint256 _temperature) public payable {
        require(msg.value > 0, "You must bet more than 0 wei");
        require(bets[msg.sender] == 0, "You already have a bet");
        require(temperature == 0, "The temperature must not be set.");
        bets[msg.sender] = _temperature;
        emit Betted(msg.sender, _temperature);
    }

    function setTemperature(uint256 _temperature) public onlyOwner {
        temperature = _temperature;
        emit TemperatureSet(_temperature);
    }

    function resetTemperature() public onlyOwner {
        temperature = 0;
    }

    function cashout() public {
        require(temperature > 0, "Temperature is not set yet");
        require(bets[msg.sender] == temperature, "You did not guess the temperature.");
        bets[msg.sender] = 0;
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "transfer failed");
    }

    function cashout_unsafe() public {
        require(temperature > 0, "Temperature is not set yet");
        require(bets[msg.sender] == temperature, "You did not guess the temperature.");
        (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "transfer failed");
        bets[msg.sender] = 0;
    }
}