// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts@4.9.3/token/ERC20/IERC20.sol";

/// @notice WETH9 interface
interface IWETH9 is IERC20 {
    function deposit() external payable;

    function withdraw(uint256 wad) external; // wad = 18 decimals
}
// This interface defines the required functions for interacting with a Wrapped Ether (WETH9) contract.
// WETH9 is an ERC20 token that represents Ether (ETH) in a fungible token form, allowing it to be traded and used within the Ethereum ecosystem.
// Details:
// The IWETH9 interface extends the IERC20 interface, which means it inherits the standard ERC20 functions like transfer, approve, and balanceOf.
// The additional functions specific to WETH9 are:
// deposit(): Allows users to convert Ether into WETH9 tokens. When Ether is deposited, an equivalent amount of WETH9 tokens is minted.
// withdraw(uint256 wad): Allows users to redeem WETH9 tokens for Ether. The specified amount (wad) of WETH9 tokens is burned, and the corresponding Ether is sent to the caller.

// Standard ERC20 Token:
// In a standard ERC20 token, the deposit() function doesn’t exist by default.
// Users typically acquire ERC20 tokens by transferring them from another address or receiving them as part of a transaction.
// The process doesn’t involve directly converting Ether (ETH) into the ERC20 token within the contract.
// WETH9’s deposit() Function:
// WETH9 is a special case because it represents Ether itself in token form.
// The deposit() function in WETH9 allows users to convert Ether into WETH9 tokens.
// Here’s how it works:
// A user sends Ether to the WETH9 contract address.
// The contract mints an equivalent amount of WETH9 tokens and assigns them to the user.
// Essentially, the user’s Ether is “wrapped” into the WETH9 token.
// This process is useful for DeFi protocols and DApps that require Ether to be represented as an ERC20 token.
// Example Usage:
// Imagine a decentralized exchange (DEX) where users can trade Ether for other tokens.
// If the DEX only supports ERC20 tokens, users can’t directly trade Ether.
// By depositing Ether into WETH9 (using the deposit() function), users can then trade WETH9 tokens on the DEX.
// When they want to withdraw Ether, they use the withdraw() function to convert WETH9 back to Ether.
// In summary, the deposit() function in the IWETH9 interface is a specialized mechanism for handling Ether-to-WETH9 conversion, making it compatible with ERC20-based systems. 🌟
