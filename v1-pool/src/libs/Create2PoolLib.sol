// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import {NapierPool} from "../NapierPool.sol";

/// @notice Library for deploying NapierPool contracts using CREATE2 opcode
/// @dev External library functions are used to downsize the factory contract
// The CREATE2 opcode allows the creation of contracts at deterministic addresses, meaning that the contract address can be precomputed before the deployment.
// The library has a function called deploy that takes two arguments: basePool and underlying. basePool is the address of the base pool contract that defines the logic and interface of the NapierPool contract. underlying is the address of the underlying token that the pool supports.
library Create2PoolLib {
    function deploy(address basePool, address underlying) external returns (NapierPool) {
        bytes32 salt;
        assembly {
            mstore(0x00, basePool) // note: ABI encoder v2 verifies the upper 96 bits are clean.
            mstore(0x20, underlying)
            salt := keccak256(0x00, 0x40)
        }
        return new NapierPool{salt: salt}();
    }
}
