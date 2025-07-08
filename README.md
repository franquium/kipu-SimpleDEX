# Simple Decentralized Exchange (DEX) wth Liquidity Pools

KipuBank is a Ethereum smart contract that allows users to deposit and withdraw native ETH from a personal vault, under strict restrictions defined at deployment. 
It follows best practices in smart contract design, using custom errors, modifiers, and the Checks-Effects-Interactions pattern to ensure safety and gas efficiency.

This project is a simple Decentralized Exchange (DEX) built on Ethereum. It allows users to swap between two specific ERC-20 tokens, **TokenA** and **TokenB**, using a liquidity pool managed by the contract owner.

This project follows best practices in smart contract design, using custom errors, modifiers, and the Checks-Effects-Interactions pattern to ensure safety and gas efficiency.



---

## Main Features

-   Swaps between two distinct ERC-20 tokens (`TokenA` and `TokenB`).
-   **Owner-only** functions to add and remove liquidity from the pool.
-   **Public** functions for any user to swap tokens.
-   A `view` function to get the current instantaneous price of a token.
-   Tracks token reserves within the liquidity pool.
-   Emits events for key actions: `LiquidityAdded`, `LiquidityRemoved`, and `TokensSwapped`.
-   All elements are documented with NatSpec

---

## Deployment Instructions

You can deploy the contract using the [Remix IDE](https://remix.ethereum.org/) with MetaMask and Sepolia testnet.

### Prerequisites

- MetaMask wallet installed and connected to Sepolia testnet
- ETH in your Sepolia wallet [use a Sepolia faucet](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)
- Contract code loaded into Remix

### Steps

1. Open [Remix IDE](https://remix.ethereum.org/)

2. Upload the codes from the repository.

3. Compile the Contract

    In the **Solidity Compiler** tab:
    - Select compiler version `^0.8.19`
    - Click on `Compile TokenA.sol` and do the same for `TokenB.sol`
    - Click on `Compile SimpleDEX.sol`

4. Deployment configures and deploy contracts

    **Deploy `TokenA.sol`**
    -   In the **Deploy & Run Transactions** tab, select `TokenA` from the `CONTRACT` dropdown.
    * In the `initialSupply` field next to the "Deploy" button, enter the desired supply (e.g., `1000000000000000000000000` for 1 million tokens).
    * Click **Deploy** and confirm in MetaMask.
    * **Copy the deployed contract address of `TokenA`.

    **Deploy `TokenB.sol`**
    -   Select `TokenB` from the `CONTRACT` dropdown.
    -   Enter the same `initialSupply`.
    -   Click **Deploy** and confirm.
    -   **Copy the deployed contract address of `TokenB`.

    **Deploy `SimpleDEX.sol`**
    -   Select `SimpleDEX` from the `CONTRACT` dropdown.
    -   In the deployment fields, paste the copied addresses:
        -   `_tokenA`: Paste `TokenA`'s address.
        -   `_tokenB`: Paste `TokenB`'s address.
    -   Click **Deploy** and confirm.

5.  Verify the contract

    Once deployed, copy your contract address and verify it at:  
        [`https://sepolia.etherscan.io/`](https://sepolia.etherscan.io/)

---

## How to Interact with the Contract

All interactions can be done through Remix’s UI or directly in the deployed contract tab:

### Owner Actions (Managing Liquidity)

_Before adding liquidity, the owner must first **approve** the DEX contract to spend their tokens._

1.  **Approve Tokens**:
    * In the deployed `TokenA` contract UI, call `approve`.
        * `spender`: The address of the `SimpleDEX` contract.
        * `amount`: The amount of `TokenA` you want to make available (e.g., `500000000000000000000000`).
    * Repeat the `approve` call for the `TokenB` contract.
2.  **Add Liquidity**:
    * In the `SimpleDEX` contract UI, call `addLiquidity(uint256 amountA, uint256 amountB)`.
    * Emits `LiquidityAdded(provider, amountA, amountB)`.
3.  **Remove Liquidity**:
    * In the `SimpleDEX` contract UI, call `removeLiquidity(uint256 amountA, uint256 amountB)`.
    * Emits `LiquidityRemoved(provider, amountA, amountB)`.

### User Actions (Swapping)

_Before swapping, a user must first **approve** the DEX contract to spend the token they wish to trade._

1.  **Approve Token for Swap**:
    * In the token contract (`TokenA` or `TokenB`), the user calls `approve`.
        * `spender`: The `SimpleDEX` address.
        * `amount`: The exact amount they want to swap.
2.  **Swap Tokens**:
    -   Call `swapAforB(uint256 amountAIn)` to trade TokenA for TokenB.
    -   Call `swapBforA(uint256 amountBIn)` to trade TokenB for TokenA.
    -   Emits `TokensSwapped(user, tokenIn, tokenOut, amountIn, amountOut)`.


### View Functions

| Function | Description |
| :--- | :--- |
| `getPrice(address _token)` | Returns the current price of one token in terms of the other (with 18 decimals). |
| `reserveA()` | Returns the total amount of `TokenA` held in the liquidity pool. |
| `reserveB()` | Returns the total amount of `TokenB` held in the liquidity pool. |

---

## Contract Address

Once deployed, your contract address will appear here:  
`https://sepolia.etherscan.io/address/<YOUR_CONTRACT_ADDRESS>`

You can verify and interact with it directly via Etherscan as well.

---

## License

This project is licensed under the [MIT License](https:github.com/franquium/kipu-SimpleDEX/blob/main/LICENSE).

---

## Author

Made with by `@franquium`  

