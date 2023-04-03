# WETHDonations report
## Vulnerability: donateWithPermit is broken and does not work as intended.
`donateWithPermit` is broken in multiple ways. We'll break them down:
- The call to `_logDonation` increases the balance of the transaction sender, not the actual donor `target`.
- `WETH9` does not implement EIP2612 permits, so the call to `permit` won't work as intended—it will instead go to the fallback function, which won't fail but rather perform a 0-amount deposit.
- As no amount was really approved, `transferFrom` will revert unless the `target` has actually approved the `msg.sender` before hand. In this case, this can cause **loss of funds**, as the tokens transferred to the donation contract are attributed to the msg.sender, not the `target`, therefore letting the `msg.sender` withdraw them after the amount of time has passed or if the exploit the vulnerability in `addLockTime`.
- In the case WETH9 had permits, the function would still be vulnerable to replay & malleability attacks, as the signature is not stored anywhere to check if it has been used before and the `s` value is not restricted. On top of this, no EIP712 structured hash is implemented.
## Vulnerability: addLockTime is vulnerable to overflow
Due to the contract allowing a compiler version pre 0.8, the contract could be compiled with a 0.7.x version and therefore contain unchecked math. it would then be possible to overflow the `lockTimes[msg.sender]` slot and allow the user to withdraw before the intended time.
## Vulnerability: Possible OOG depending on withdrawal method due to `.transfer()` usage
The `withdraw` function, while reentrancy safe, it uses `.transfer` to send the user's balance. This only forwards 2100 gas, and therefore any complex interactions which are not direct withdrawals through an EOA might fail.
## Vulnerability: No way to freeze the implementation
As the contract will be deployed as a proxy, ideally the implementation would be freezed so that users always have to go through the proxy. Consider implementing a freeze functionality.
## Note: No natspec usage.
Please consider using natspec for documentation.
## Note: No events emitted on `donate`, `donateWithPermit`, `addLockTime` nor `withdraw`
Please consider emitting events on these interactions, as it will help with indexing usage of the contract.
# Note: Use uint256 instead of uint256 for clarity
Please consider using uint256 instead of `uint` for removing any doubt or clarity over types.
# Note: The `weth` variable could be a constant
As the contract is written on the assumptions of the canonical WETH contract, it could become a constant to signal it should not be changed.
