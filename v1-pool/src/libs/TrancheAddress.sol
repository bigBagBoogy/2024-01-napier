// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import {ITranche} from "@napier/napier-v1/src/interfaces/ITranche.sol";
import {Create2} from "@openzeppelin/contracts@4.9.3/utils/Create2.sol";

library TrancheAddress {
    function computeAddress(address adapter, uint256 maturity, bytes32 initHash, address factory)
        internal
        pure
        returns (ITranche tranche)
    {
        //  similar to the PoolAddress.sol, but it is for computing the address of a Tranche contract instead of a NapierPool contract. A Tranche is a contract that represents a fixed-rate, fixed-term loan backed by an underlying asset in the Napier protocol
        // Optimize salt computation
        // https://www.rareskills.io/post/gas-optimization#viewer-ed7oh
        // https://github.com/dragonfly-xyz/useful-solidity-patterns/tree/main/patterns/assembly-tricks-1#hash-two-words
        bytes32 salt;
        assembly {
            // Clean the upper 96 bits of `adapter` in case they are dirty.
            mstore(0x00, shr(96, shl(96, adapter)))
            mstore(0x20, maturity) // maturity is the timestamp of the loan maturity date
            salt := keccak256(0x00, 0x40)
        }
        tranche = ITranche(Create2.computeAddress(salt, initHash, factory));
    }
}
