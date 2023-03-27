# Pool.sol audit

## Note: Pausable is not used but it is imported
The `Pausable.sol` contract is imported, but it is not inherited by the Pool.

## Note: No SDPX license identifier
There's no license specifier on the Pool contract. It is customary by convention to include one.

## Note: Dangling TODO on constructor
There's is a dangling todo on the constructor.
## Vulnerability: Swap event argument in swapEthForToken is switched up
The swap event has the following signature: 
`Swap(address indexed sender, uint256 xIn, uint256 yIn, uint256 xOut, uint256 yOut);`
Where `x` is ETH, and `y` is the ERC20 Token. However, on `swapEthForToken`, `msg.value` is on the `yIn` spot instead of the `xIn` spot, and `beta` is on the `xOut` instead of the `yOut` spot.

**Fix:** change line 62 to:
```solidity
Swap(msg.sender, msg.value, 0, 0, beta);
```

## Vulnerability: Swap event argument in swapTokenForEth is switched up
Similar to the issue above, in `swapTokenForEth`, the arguments are switched, namely, `_amount` is on the `xIn` spot, and `alpha` on the `yOut` spot.

**Fix:** change line 62 to:
```solidity
Swap(msg.sender, 0, _amount, alpha, 0);
```


## Vulnerability: precision issues in getETHPriceInToken
As soon as x is bigger than y, due to lack of precision, the ETH Price will always be 0. This is innaccurate, as this will not be the priced incurred when trading. A simple example of this scenario is a pool with 2 ETH and 1 ERC20 token. Assuming both ETH and ERC20 have 18 decimals, the price of ETH should be `5x10^17` ERC20, but the `getETHPriceInToken` will return 0, as solidity will just round down to 0.

**Fix:** use a fixed-point math library with higher precision.

## Vulnerability: Swaps do not expire, leaving them prone to long-tail MEV strategies and multi-block price manipulation
Swaps do not implement a `deadline`, which would allow the user to willingly set a duration for which the trade is valid. As this is not implemented, apart from the ever-present atomic MEV arbitrage, this also leaves the swaps vulnerable to multi-block price manipulation, giving the user a worse price or making them completely miss a trade.
**Fix:** Implement a `deadline` and check against `block.timestamp`.

## Vulnerability: No slippage protection implemented on swap functions
in constant-product AMMs, slippage protection is an extremely important feature—due to uncertainty on inclusion of the transaction, big price fluctuations can happen, especially on pairs with low-liquidity. On the swap functions, there's no way for the user to specify slippage preferences, meaning that they're open to big losses on volatile markets and predatory MEV/price manipulation strategies.

**Fix:** Implement slippage protection—a good strategy is to use Uniswap's model in which the user inputs the minimum amount of tokens to receive on swap, essentially acting like a limit order if the price moves enough for the user not to receive the tokens.