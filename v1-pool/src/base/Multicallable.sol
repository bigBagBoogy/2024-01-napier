// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.10;

/// @title Multicallable
/// @notice Enables calling multiple methods in a single call to the contract
/// @dev Forked from Uniswap v3 periphery: https://github.com/Uniswap/v3-periphery/blob/main/contracts/base/Multicallable.sol
/// @dev Apply `DELEGATECALL` with the current contract to each calldata in `data`,
/// and store the `abi.encode` formatted results of each `DELEGATECALL` into `results`.
/// If any of the `DELEGATECALL`s reverts, the entire context is reverted,
/// and the error is bubbled up.
///
// Combining Multicallable with msg.value can cause double spending issues.
/// (See: https://www.paradigm.xyz/2021/08/two-rights-might-make-a-wrong)
abstract contract Multicallable {
    function multicall(bytes[] calldata data) external payable returns (bytes[] memory results) {
        // The delegatecall function does not check the validity of the data passed to it, such as the length, format, or type of the arguments.
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length;) {
            (bool success, bytes memory returndata) = address(this).delegatecall(data[i]);

            if (!success) {
                // Bubble up the revert message.
                // https://github.com/dragonfly-xyz/useful-solidity-patterns/tree/main/patterns/error-handling
                // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/36bf1e46fa811f0f07d38eb9cfbc69a955f300ce/contracts/utils/Address.sol#L151-L154
                assembly {
                    revert(
                        // Start of revert data bytes.
                        add(returndata, 0x20),
                        // Length of revert data.
                        mload(returndata)
                    )
                }
            }

            results[i] = returndata;

            unchecked {
                ++i;
            }
        }
    }
}
// The Multicallable contract is a useful contract that allows users to execute multiple functions in a single transaction, saving gas and time. However, it also introduces some security risks that need to be considered. Some of the possible risks are:

// Reentrancy: The delegatecall function can call any function in the current contract, including the ones that are not intended to be called by the user. This can create a reentrancy vulnerability, where an attacker can exploit a function that updates the state after an external call, and call it repeatedly before the state is updated. To prevent reentrancy, the contract should use a reentrancy guard modifier, such as the one provided by OpenZeppelin1, or follow the checks-effects-interactions pattern2.
// Data validation: The delegatecall function does not check the validity of the data passed to it, such as the length, format, or type of the arguments. This can lead to unexpected errors or malicious inputs that can compromise the contract logic or security. To prevent data validation issues, the contract should validate the data before passing it to the delegatecall function, or use a whitelist of allowed functions that can be called by the delegatecall function3.
// Error handling: The delegatecall function can revert for various reasons, such as invalid opcode, out of gas, or assertion failure. The contract handles the revert by bubbling up the error message using assembly code. However, this may not be sufficient or desirable in some cases, as the error message may not be informative, user-friendly, or consistent with the contract design. To improve error handling, the contract should use custom error codes or messages, or use a try-catch statement to handle the revert .
