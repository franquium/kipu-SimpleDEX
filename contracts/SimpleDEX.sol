// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title SimpleDEX
 * @author franquium
 * @notice A decentralized exchange for swapping TokenA and TokenB using a constant product formula
 * @dev Only the owner can add/remove liquidity. Any user can swap tokens or get price
 */
contract SimpleDEX is Ownable {
    /// @notice The TokenA contract address (immutable after deployment)
    IERC20 public immutable tokenA;

    /// @notice The TokenB contract address (immutable after deployment)
    IERC20 public immutable tokenB;

    /// @notice Current pool reserves of TokenA
    uint256 public reserveA;

    /// @notice Current pool reserves of TokenB
    uint256 public reserveB;

    // ------------------------------------------------------------------------
    // Custom Errors
    // ------------------------------------------------------------------------

    /// @notice Thrown when a caller is not the owner
    error NotOwner();

    /// @notice Thrown when trying to remove or swap more tokens than available in pool
    error InsufficientLiquidity();

    /// @notice Thrown when an invalid token address is provided
    error InvalidToken();

    /// @notice Thrown when a zero amount is provided where not allowed
    error ZeroAmount();

    // ------------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------------

    /**
     * @notice Emitted when liquidity is added to the pool
     * @param provider Address adding liquidity
     * @param amountA Amount of TokenA added
     * @param amountB Amount of TokenB added
     */
    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);

    /**
     * @notice Emitted when liquidity is removed from the pool
     * @param provider Address removing liquidity
     * @param amountA Amount of TokenA removed
     * @param amountB Amount of TokenB removed
     */
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);

    /**
     * @notice Emitted when tokens are swapped
     * @param user Address performing the swap
     * @param tokenIn Address of token sent in
     * @param tokenOut Address of token received
     * @param amountIn Amount of token sent in
     * @param amountOut Amount of token received
     */
    event TokensSwapped(
        address indexed user,
        address indexed tokenIn,
        address indexed tokenOut,
        uint256 amountIn,
        uint256 amountOut
    );

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------

    /**
     * @notice Initializes the DEX with TokenA and TokenB contract addresses
     * @param _tokenA Address of TokenA
     * @param _tokenB Address of TokenB
     */
    constructor(address _tokenA, address _tokenB) Ownable(msg.sender) {
        if (_tokenA == address(0) || _tokenB == address(0) || _tokenA == _tokenB) revert InvalidToken();
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    // ------------------------------------------------------------------------
    // Modifiers
    // ------------------------------------------------------------------------

    /**
     * @notice Ensures only the owner can call certain functions.
     */
    modifier onlyDEXOwner() {
        if (owner() != msg.sender) revert NotOwner();
        _;
    }

    /**
     * @notice Validates that the amount is greater than zero.
     * @param amount The amount to check.
     */
    modifier nonZero(uint256 amount) {
        if (amount == 0) revert ZeroAmount();
        _;
    }

    // ------------------------------------------------------------------------
    // Functions
    // ------------------------------------------------------------------------

    /**
     * @notice Adds liquidity to the pool. Only callable by the owner
     * @param amountA Amount of TokenA to add
     * @param amountB Amount of TokenB to add
     */
    function addLiquidity(uint256 amountA, uint256 amountB)
        external
        onlyDEXOwner
        nonZero(amountA)
        nonZero(amountB)
    {
        // Effects
        reserveA += amountA;
        reserveB += amountB;

        // Interactions
        if (!tokenA.transferFrom(msg.sender, address(this), amountA)) revert InsufficientLiquidity();
        if (!tokenB.transferFrom(msg.sender, address(this), amountB)) revert InsufficientLiquidity();

        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    /**
     * @notice Removes liquidity from the pool. Only callable by the owner
     * @dev Owner receives tokens from the pool
     * @param amountA Amount of TokenA to remove
     * @param amountB Amount of TokenB to remove
     */
    function removeLiquidity(uint256 amountA, uint256 amountB)
        external
        onlyDEXOwner
        nonZero(amountA)
        nonZero(amountB)
    {
        if (amountA > reserveA || amountB > reserveB) revert InsufficientLiquidity();

        // Effects
        reserveA -= amountA;
        reserveB -= amountB;

        // Interactions
        if (!tokenA.transfer(msg.sender, amountA)) revert InsufficientLiquidity();
        if (!tokenB.transfer(msg.sender, amountB)) revert InsufficientLiquidity();

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    /**
     * @notice Swaps TokenA for TokenB using the constant product formula
     * @dev User must approve this contract for TokenA before calling
     * @param amountAIn Amount of TokenA to swap
     */
    function swapAforB(uint256 amountAIn)
        external
        nonZero(amountAIn)
    {
        // Checks
        if (reserveA + amountAIn == 0 || reserveB == 0) revert InsufficientLiquidity();

        // Constant product formula: (x + dx) * (y - dy) = x * y
        uint256 amountBOut = (reserveB * amountAIn) / (reserveA + amountAIn);
        if (amountBOut == 0 || amountBOut > reserveB) revert InsufficientLiquidity();

        // Effects
        reserveA += amountAIn;
        reserveB -= amountBOut;

        // Interactions
        if (!tokenA.transferFrom(msg.sender, address(this), amountAIn)) revert InsufficientLiquidity();
        if (!tokenB.transfer(msg.sender, amountBOut)) revert InsufficientLiquidity();

        emit TokensSwapped(msg.sender, address(tokenA), address(tokenB), amountAIn, amountBOut);
    }

    /**
     * @notice Swaps TokenB for TokenA using the constant product formula
     * @dev User must approve this contract for TokenB before calling
     * @param amountBIn Amount of TokenB to swap
     */
    function swapBforA(uint256 amountBIn)
        external
        nonZero(amountBIn)
    {
        // Checks
        if (reserveB + amountBIn == 0 || reserveA == 0) revert InsufficientLiquidity();

        // Constant product formula: (x - dx) * (y + dy) = x * y
        uint256 amountAOut = (reserveA * amountBIn) / (reserveB + amountBIn);
        if (amountAOut == 0 || amountAOut > reserveA) revert InsufficientLiquidity();

        // Effects
        reserveB += amountBIn;
        reserveA -= amountAOut;

        // Interactions
        if (!tokenB.transferFrom(msg.sender, address(this), amountBIn)) revert InsufficientLiquidity();
        if (!tokenA.transfer(msg.sender, amountAOut)) revert InsufficientLiquidity();

        emit TokensSwapped(msg.sender, address(tokenB), address(tokenA), amountBIn, amountAOut);
    }

    /**
     * @notice Returns the price of a token in terms of the other token
     * @dev Returns the price as a ratio (reserveOther / reserveThis)
     * @param _token The address of the token to price
     * @return price The price of one token (with 18 decimals)
     */
    function getPrice(address _token) external view returns (uint256 price) {
        if (_token == address(tokenA)) {
            if (reserveA == 0) return 0;
            return (reserveB * 1e18) / reserveA;
        } else if (_token == address(tokenB)) {
            if (reserveB == 0) return 0;
            return (reserveA * 1e18) / reserveB;
        } else {
            revert InvalidToken();
        }
    }
}