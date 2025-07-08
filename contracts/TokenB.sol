// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TokenB
 * @author franquium
 * @notice A simple ERC-20 token 
 * @dev Standard ERC20 implementation using OpenZeppelin
 */
contract TokenB is ERC20, Ownable {
    /**
     * @notice Mints the initial supply of tokens to the contract deployer
     * @param initialSupply The total amount of tokens to mint
     */
    constructor(uint256 initialSupply) ERC20("TokenB", "TKB") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply);
    }
}