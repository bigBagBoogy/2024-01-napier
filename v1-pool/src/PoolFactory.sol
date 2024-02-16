// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.19;

// interfaces
import {IPoolFactory} from "./interfaces/IPoolFactory.sol";
import {CurveTricryptoOptimizedWETH} from "./interfaces/external/CurveTricryptoOptimizedWETH.sol";
import {CurveTricryptoFactory} from "./interfaces/external/CurveTricryptoFactory.sol";
import {ITranche} from "@napier/napier-v1/src/interfaces/ITranche.sol";
// libs
import {NapierPool} from "./NapierPool.sol";
import {PoolAddress} from "./libs/PoolAddress.sol";
import {Create2PoolLib} from "./libs/Create2PoolLib.sol";
import {Errors} from "./libs/Errors.sol";
import {MAX_LN_FEE_RATE_ROOT, MAX_PROTOCOL_FEE_PERCENT, MIN_INITIAL_ANCHOR} from "./libs/Constants.sol";
// inherits
import {Ownable2Step, Ownable} from "@openzeppelin/contracts@4.9.3/access/Ownable2Step.sol";

contract PoolFactory is IPoolFactory, Ownable2Step {
    /// @notice Keccak256 hash of Pool creation code
    /// @dev Used to compute the CREATE2 address
    bytes32 public immutable POOL_CREATION_HASH = keccak256(type(NapierPool).creationCode);

    /// @notice Curve v2 Tricrypto Factory (aka tricrypto-ng)
    /// @dev Note: Curve pool used as BasePool for NapierPool MUST be deployed by this contract.
    CurveTricryptoFactory public immutable curveTricryptoFactory;

    /// @notice Temporary variable
    InitArgs private _tempArgs;

    /// @notice Mapping of NapierPool to PoolAssets
    mapping(address => PoolAssets) internal _pools;

    /// @notice Authorized callback receivers for pool flashswap
    mapping(address => bool) internal _authorizedCallbackReceivers;

    /// @dev Note: params can be zero-address
    /// @param _curveTricryptoFactory Immutable Curve Tricrypto Factory
    /// @param _owner Owner of this factory
    constructor(address _curveTricryptoFactory, address _owner) {
        curveTricryptoFactory = CurveTricryptoFactory(_curveTricryptoFactory);

        _transferOwnership(_owner);
    }

    /// @notice Deploys a new NapierPool contract. Only callable by owner
    /// @dev BasePool assets must be Napier Principal Token.
    /// @param basePool Curve Tricrypto pool address deployed by `CurveTricryptoFactory`.
    /// @param underlying Underlying asset. Must be the same as the underlying asset of the basePool.
    /// @param poolConfig NapierPool configuration. fee and AMM configs.
    function deploy(address basePool, address underlying, PoolConfig calldata poolConfig)
        external
        override
        onlyOwner
        returns (address)
    {
        if (poolConfig.lnFeeRateRoot > MAX_LN_FEE_RATE_ROOT) revert Errors.LnFeeRateRootTooHigh();
        if (poolConfig.protocolFeePercent > MAX_PROTOCOL_FEE_PERCENT) revert Errors.ProtocolFeePercentTooHigh();
        if (poolConfig.initialAnchor < MIN_INITIAL_ANCHOR) revert Errors.InitialAnchorTooLow();

        address computedAddr = poolFor(basePool, underlying);
        if (_pools[computedAddr].underlying != address(0)) revert Errors.FactoryPoolAlreadyExists();

        address[3] memory pts = curveTricryptoFactory.get_coins(basePool);

        // Checklist:
        // 1. Base pool must be deployed by `CurveTricryptoFactory`.
        // 2. Underlying asset must be the same as the underlying asset of the principal tokens.
        // 3. Maturity of the principal tokens must be the same.
        uint256 maturity = ITranche(pts[0]).maturity();
        if (maturity != ITranche(pts[1]).maturity() || maturity != ITranche(pts[2]).maturity()) {
            revert Errors.FactoryMaturityMismatch();
        }
        if (
            ITranche(pts[0]).underlying() != underlying || ITranche(pts[1]).underlying() != underlying
                || ITranche(pts[2]).underlying() != underlying
        ) revert Errors.FactoryUnderlyingMismatch();

        // Set temporary variable
        _tempArgs = InitArgs({
            assets: PoolAssets({basePool: basePool, underlying: underlying, principalTokens: pts}),
            configs: poolConfig
        });
        // Deploy pool and temporary variable is read by callback from the pool
        address pool = address(Create2PoolLib.deploy(basePool, underlying));
        _pools[pool] = _tempArgs.assets;

        // Reset temporary variable to 0-value
        delete _tempArgs;

        emit Deployed(basePool, underlying, pool);
        return pool;
    }

    /////////////////////////////////////////////////////////////////////
    // View methods
    /////////////////////////////////////////////////////////////////////

    /// @notice Returns the pool parameters used to deploy the pool
    /// @dev This would be used while the pool is deploying
    /// @return The pool parameters used to initialize the pool
    function args() external view override returns (InitArgs memory) {
        return _tempArgs;
    }

    /// @notice Calculate the address of a pool with CREATE2
    /// @param basePool Curve Tricrypto pool address
    /// @param underlying Underlying asset (e.g. DAI, WETH...)
    function poolFor(address basePool, address underlying) public view override returns (address) {
        return address(PoolAddress.computeAddress(basePool, underlying, POOL_CREATION_HASH, address(this)));
    }

    /// @dev Returns the pool parameters used to deploy the pool
    /// @dev This function doesn't revert even if the pool doesn't exist. It returns the default values in that case.
    /// @param pool A pool address
    /// @return The pool parameters
    function getPoolAssets(address pool) external view override returns (PoolAssets memory) {
        return _pools[pool];
    }

    /// @notice Returns the owner of this contract
    /// @notice Note: Owner is also the owner of the pools deployed by this factory
    function owner() public view override(Ownable, IPoolFactory) returns (address) {
        return Ownable.owner();
    }

    /// @notice Returns true if the callback is authorized to receive callbacks from pools
    /// @param callback An address to check
    function isCallbackReceiverAuthorized(address callback) external view override returns (bool) {
        return _authorizedCallbackReceivers[callback];
    }

    ///////////////////////////////////////////////////////////////////////////
    // Mutative methods
    ///////////////////////////////////////////////////////////////////////////

    function authorizeCallbackReceiver(address callback) external override onlyOwner {
        _authorizedCallbackReceivers[callback] = true;
        emit AuthorizedCallbackReceiver(callback);
    }

    function revokeCallbackReceiver(address callback) external override onlyOwner {
        _authorizedCallbackReceivers[callback] = false;
        emit RevokedCallbackReceiver(callback);
    }
}
// This contract is called PoolFactory and it is part of the Napier Protocol, which is a liquidity hub for yield trading built as an extension of Curve Finance1. The contract has the following features:

// It inherits from two interfaces: IPoolFactory and Ownable2Step. The first one defines the functions for deploying and managing NapierPool contracts, which are the core of the Napier AMM. The second one defines the functions for transferring and renouncing ownership of the contract.
// It has a constant variable called POOL_CREATION_HASH, which is the hash of the NapierPool creation code. This is used to compute the address of the NapierPool contracts using the CREATE2 opcode, which allows for deterministic deployment of contracts.
// It has an immutable variable called curveTricryptoFactory, which is the address of the Curve v2 Tricrypto Factory contract. This contract is responsible for deploying and managing Curve Tricrypto pools, which are used as base pools for NapierPool contracts. A base pool is a pool that holds three principal tokens (PTs) and their underlying asset. A PT is a fixed-income equivalent of a yield-bearing token, such as aDAI or cDAI. A PT has a maturity date, which is the date when it can be redeemed for its underlying asset plus accrued interest.
// It has a private variable called _tempArgs, which is a struct of type InitArgs. This struct contains the assets and the configs for deploying a NapierPool contract. The assets are the base pool address, the underlying asset address, and an array of three PT addresses. The configs are the fee rate, the protocol fee percent, and the initial anchor for the NapierPool contract. The _tempArgs variable is used as a temporary storage for passing the arguments to the NapierPool constructor via a callback function.
// It has a mapping called _pools, which maps the address of a NapierPool contract to its assets. This is used to keep track of the deployed NapierPool contracts and their associated assets.
// It has a mapping called _authorizedCallbackReceivers, which maps the address of a contract to a boolean value. This is used to authorize certain contracts to call the callback function of the PoolFactory contract, which is required for deploying a NapierPool contract using CREATE2.
// It has a constructor that takes two arguments: _curveTricryptoFactory and _owner. The constructor sets the curveTricryptoFactory variable to the given address and transfers the ownership of the contract to the given address.
// It has a function called deploy, which is only callable by the owner of the contract. This function takes three arguments: basePool, underlying, and poolConfig. The function deploys a new NapierPool contract using the given arguments and returns its address. The function also performs some checks and validations on the arguments, such as:
// The basePool must be deployed by the curveTricryptoFactory contract.
// The underlying asset must be the same as the underlying asset of the PTs in the basePool.
// The maturity of the PTs in the basePool must be the same.
// The fee rate, the protocol fee percent, and the initial anchor must be within certain limits.
// The computed address of the NapierPool contract must not already exist in the _pools mapping.
// The function also sets the _tempArgs variable to the given arguments, deploys the NapierPool contract using the Create2PoolLib library, adds the NapierPool address and assets to the _pools mapping, deletes the _tempArgs variable, and emits a Deployed event.
