// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;
// this contract makes WETH9 immutable for all periphery contracts
// q what if a periphery contract was forgotten to make WETH9 immutable?

import {IWETH9} from "src/interfaces/external/IWETH9.sol";
// The constructor takes an argument of type IWETH9, which is an interface for the Wrapped Ether token contract, and assigns it to WETH9. This contract is inherited by most periphery contracts in the Uniswap V3 protocol, which use WETH9 to handle swaps involving Ether
/// @title Periphery Immutable State // Periphery = outlier, addon, proxy, at the outer limit
/// @notice Common immutable state used by periphery contracts

abstract contract PeripheryImmutableState {
    /// @notice Wrapped Ether
    IWETH9 public immutable WETH9;

    constructor(IWETH9 _WETH9) {
        WETH9 = _WETH9;
    }
}
// The abstract keyword is used to declare an abstract contract in Solidity. An abstract contract is a contract that has at least one function without its implementation or in the case when you don’t provide arguments for all of the base contract constructors1. An abstract contract cannot be deployed by itself, it must be inherited by another contract that implements all the functions of the abstract contract2. The abstract keyword helps to define the structure and interface of a contract, and allows the child contract to reuse and override its functions. For example:

// // This is an abstract contract
// abstract contract Animal {
//     // This is an abstract function (no implementation body)
//     function makeSound() public virtual returns (string memory);
// }

// // This is a concrete contract that inherits from Animal
// contract Dog is Animal {
//     // This is an implemented function that overrides the abstract function
//     function makeSound() public override returns (string memory) {
//         return "Woof";
//     }
// }
