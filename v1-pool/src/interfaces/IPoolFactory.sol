// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

// An interface for the PoolFactory contract
interface IPoolFactory {
    // An event that is emitted when a new NapierPool contract is deployed
    event Deployed(address indexed basePool, address indexed underlying, address indexed pool);
    // An event that is emitted when a callback receiver is authorized
    event AuthorizedCallbackReceiver(address indexed callback);
    // An event that is emitted when a callback receiver is revoked
    event RevokedCallbackReceiver(address indexed callback);

    // A struct that defines the assets of a NapierPool contract
    struct PoolAssets {
        address basePool; // The address of the base pool contract, which provides the LP token for the NapierPool
        address underlying; // The address of the underlying token, which is the main asset of the NapierPool
        address[3] principalTokens; // An array of the addresses of the Principal tokens, which represent the user's position in the NapierPool with different leverage levels
    }

    // A struct that defines the configuration of a NapierPool contract
    struct PoolConfig {
        int256 initialAnchor; // The initial anchor value, which represents the initial price of the Principal token in terms of the underlying token
        uint256 scalarRoot; // The scalar root value, which determines the curvature of the pool curve
        uint80 lnFeeRateRoot; // The logarithmic fee rate root value, which determines the fee rate of the pool
        uint8 protocolFeePercent; // The protocol fee percent value, which determines the percentage of the fee that goes to the protocol
        address feeRecipient; // The address of the fee recipient, which receives the protocol fee
    }

    // A struct that defines the initialization arguments of a NapierPool contract
    struct InitArgs {
        PoolAssets assets; // The assets of the NapierPool contract
        PoolConfig configs; // The configuration of the NapierPool contract
    }

    /// @notice Deploy a new NapierPool contract.
    /// @dev Only the factory owner can call this function. // e onlyOwner present The deploy function is onlyOwner in PoolFactory.sol, which means that only the owner of the contract can call it. However, this modifier does not need to be repeated in the interface, because modifiers are not part of the function signature1. An interface only defines the function name, parameters, and return values, but not the implementation details or modifiers2. Therefore, the deploy function in the interface does not have the onlyOwner modifier, but it still inherits it from the PoolFactory contract that implements the interface.
    /// @param basePool The address of the base pool contract
    /// @param underlying The address of the underlying token
    /// @param poolConfig The configuration of the NapierPool contract
    /// @return The address of the deployed NapierPool contract
    function deploy(address basePool, address underlying, PoolConfig calldata poolConfig) external returns (address);

    /// @notice Authorize a swap callback receiver
    /// @dev Only the factory owner can call this function.
    /// @param callback The address of the callback receiver
    /// @dev A callback receiver is a contract that implements the INapierSwapCallback interface, which defines a callback function that is invoked by the NapierPool contract after executing a token swap
    function authorizeCallbackReceiver(address callback) external;

    /// @notice Revoke a swap callback receiver authorization
    /// @dev Only the factory owner can call this function.
    /// @param callback The address of the callback receiver
    function revokeCallbackReceiver(address callback) external;

    /// @notice Check if a swap callback receiver is authorized
    /// @param callback The address of the callback receiver
    /// @return True if the callback receiver is authorized, false otherwise
    function isCallbackReceiverAuthorized(address callback) external view returns (bool);

    /// @notice Calculate the address of a NapierPool contract with CREATE2 using the base pool and underlying token as salt
    /// @param basePool The address of the base pool contract
    /// @param underlying The address of the underlying token
    /// @return The address of the NapierPool contract
    function poolFor(address basePool, address underlying) external view returns (address);

    /// @notice Get the assets of a NapierPool contract
    /// @param pool The address of the NapierPool contract
    /// @dev This function doesn't revert even if the pool doesn't exist. It returns the default values in that case.
    /// @return The assets of the NapierPool contract
    function getPoolAssets(address pool) external view returns (PoolAssets memory);

    /// @notice Get the owner of the PoolFactory contract
    /// @return The address of the owner
    // q is this not always the same? What happens if the owner changes?
    // so pools are "ownable"?
    function owner() external view returns (address);

    /// @notice Get the initialization arguments of the PoolFactory contract
    /// @return The initialization arguments
    function args() external view returns (InitArgs memory);

    /// @notice Get the pool creation hash of the PoolFactory contract
    /// @dev This is a constant value that is used to compute the address of a NapierPool contract with CREATE2
    /// @return The pool creation hash
    function POOL_CREATION_HASH() external view returns (bytes32);
}
