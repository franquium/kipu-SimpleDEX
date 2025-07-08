// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TokenA
 * @author franquium
 * @notice A simple ERC-20 token 
 * @dev Standard ERC20 implementation using OpenZeppelin
 */
contract TokenA is ERC20, Ownable {
    /**
     * @notice Mints the initial supply of tokens to the contract deployer
     * @param initialSupply The total amount of tokens to mint
     */
    constructor(uint256 initialSupply) ERC20("TokenA", "TKA") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }
}