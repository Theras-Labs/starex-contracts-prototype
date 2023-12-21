# Atomic Swap Protocol

The atomic swap protocol initially caused some confusion for me due to the absence of a native currency in the ledger. Initially, I considered the need for a dedicated ERC-20 token for the ledger, as in typical blockchain swap protocols where two tokens are exchanged. However, I now understand that the term "swap" in this context refers to the exchange of ledger balances, which can be associated with various ERC-20 tokens.

## Integration and setup

To setup the swap protocol with the ext-ledger contract, the provided test scenario for swap offers some insights. This involves setting up an aggregator to determine the value of the currency used in the ledger. It's essential to identify whether the ledger employs points (requiring a custom oracle) or a real-world currency.

The current swap protocol operates with a single base currency, the ledger's currency. However, it allows trading with multiple ERC-20 tokens. For instance, if the ledger's currency is USD, trading pairs like WETH/USD or WBTC/USD can be added.

## Changing Ledger's Currency

The protocol supports changing the ledger's currency, but this action needs careful consideration. Altering the ledger's currency could impact existing currency trades. Implementing a pause feature can mitigate potential issues during such changes.

## Ledger Extension

To support the swap protocol, the ledger is extended with a feature to store data for ERC-20 tokens used in trades.

## Further Enhancements

For more advanced functionality, potential enhancements could include:

- Implementing a DEADLINE system for trades.
- Introducing RESERVES to enhance liquidity management.
- Consideration of features similar to Uniswap, such as separate Liquidity Pool contracts.
- Exploring the possibility of making the contract upgradeable for easier updates.

It's worth noting that the decision to implement these advanced features may depend on project requirements and constraints. As of now, I haven't ventured into these enhancements due to uncertainty about project limitations.

Below are the scenario test I write with the detail of their balances:

![Swap Test ](../../images/swap-test.png)
