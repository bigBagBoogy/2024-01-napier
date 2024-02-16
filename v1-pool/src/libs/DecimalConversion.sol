// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;
// An 18 fixed point amount is a way of representing a fractional number using an integer with 18 decimal places. For example, the number 1.5 can be represented as 1500000000000000000 in 18 fixed point notation. This means that the number is implicitly multiplied by 10^-18, or 0.000000000000000001.

library DecimalConversion {
    /// @dev Turns a token into 18 point decimal
    /// @param amount The amount of the token in native decimal encoding
    /// @param decimals The token decimals (MUST be less than 18)
    /// @return The amount of token encoded into 18 point fixed point
    function to18Decimals(uint256 amount, uint8 decimals) internal pure returns (uint256) {
        // we shift left by the difference
        return amount * 10 ** (18 - decimals);
    }

    /// @dev Turns an 18 fixed point amount into a token amount
    /// @param amount The amount of the token in 18 decimal fixed point
    /// @param decimals The token decimals (MUST be less than 18)
    /// @return The amount of token encoded in native decimal point
    function from18Decimals(uint256 amount, uint8 decimals) internal pure returns (uint256) {
        // we shift right the amount by the number of decimals
        return amount / 10 ** (18 - decimals);
    }
}
// can be useful for smart contracts that deal with tokens that have different decimals, such as ERC20 or BEP20 tokens12. For example, if a contract needs to calculate the ratio of two tokens that have different decimals, it can use this library to convert both tokens to 18 fixed point amounts, and then perform the calculation. Alternatively, if a contract needs to display the balance of a token that has less than 18 decimals, it can use this library to convert the token amount to its native decimal point. This library can help avoid the loss of precision or overflow that can occur with floating point numbers
