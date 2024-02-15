// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import {INapierPool} from "../interfaces/INapierPool.sol";
import {Create2} from "@openzeppelin/contracts@4.9.3/utils/Create2.sol";

library PoolAddress {
    function computeAddress(address basePool, address underlying, bytes32 initHash, address factory)
        internal
        pure
        returns (INapierPool pool)
    {
        // Optimize salt computation
        // https://www.rareskills.io/post/gas-optimization#viewer-ed7oh
        // https://github.com/dragonfly-xyz/useful-solidity-patterns/tree/main/patterns/assembly-tricks-1#hash-two-words
        bytes32 salt;
        assembly {
            // Clean the upper 96 bits of `basePool` in case they are dirty.
            mstore(0x00, shr(96, shl(96, basePool)))
            mstore(0x20, shr(96, shl(96, underlying)))
            salt := keccak256(0x00, 0x40)
        }
        pool = INapierPool(Create2.computeAddress(salt, initHash, factory));
    }
}
// This code is a library for computing the address of a NapierPool contract using the CREATE2 opcode. NapierPool is a contract that implements a liquidity pool for the Napier protocol, which is a decentralized exchange platform1. The library has a function called computeAddress that takes four arguments: basePool, underlying, initHash, and factory. basePool is the address of the base pool contract that defines the logic and interface of the NapierPool contract. underlying is the address of the underlying token that the pool supports. initHash is the hash of the initialization code of the NapierPool contract. factory is the address of the contract that deploys the NapierPool contracts. The function uses assembly to store the first two arguments in memory and compute a salt value, which is a random number that ensures the uniqueness of the deployed contract address. Then, the function uses the Create2 library from OpenZeppelin2 to compute the address of the NapierPool contract using the salt, the initHash, and the factory. The function returns the address of the NapierPool contract as an interface type INapierPool.
