// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// https://github.com/curvefi/tricrypto-ng/blob/0bc1191b6097c8854e4f09e385f6c2c79a5bb773/contracts/main/CurveTricryptoOptimizedWETH.vy

interface CurveTricryptoFactory {
    /// @notice Get the coins within a pool
    /// @param pool Address of the pool
    /// @return address[3] Array of the 3 coins in the pool
    function get_coins(address pool) external view returns (address[3] memory);

    //////////////////////////////////////////////////////////////////////
    // Protected methods
    //////////////////////////////////////////////////////////////////////

    // function deploy_pool(
    //     string memory _name,
    //     string memory _symbol,
    //     address[3] calldata _coins,
    //     address _weth,
    //     uint256 implementation_id,
    //     uint256 A,
    //     uint256 gamma,
    //     uint256 mid_fee,
    //     uint256 out_fee,
    //     uint256 fee_gamma,
    //     uint256 allowed_extra_profit,
    //     uint256 adjustment_step,
    //     uint256 ma_exp_time,
    //     uint256[2] calldata initial_prices
    // ) external returns (address);

    function set_pool_implementation(address _pool_implementation, uint256 _implementation_index) external;

    function set_gauge_implementation(address _gauge_implementation) external;

    function set_views_implementation(address _views_implementation) external;

    function set_math_implementation(address _math_implementation) external;
}

// Copilot
// This interface defines the functions of the CurveTricryptoFactory contract, which is the main contract used to deploy and manage metapools on Curve1. Metapools are liquidity pools that contain three tokens: two ERC20 tokens and one base pool token. The base pool token is an LP token from another Curve pool, such as 3Pool or sBTC. Metapools allow users to swap between any of the three tokens with low slippage and high capital efficiency2.

// The functions in this interface are:

// get_coins: returns the addresses of the three tokens in a given metapool. The first and second elements are the ERC20 tokens, and the third element is the base pool token.
// deploy_pool: deploys a new metapool with the given parameters, such as the name, the symbol, the coins, the fees, the curve parameters, and the initial prices. This function is commented out because it is only accessible by the factory owner or the Idle governance3.
// set_pool_implementation: sets the implementation contract address for a given metapool. The implementation contract contains the core logic of the metapool, such as the swap, deposit, and withdraw functions. This function allows the factory owner or the Idle governance to upgrade or migrate the metapool to a new implementation.
// set_gauge_implementation: sets the implementation contract address for the gauge contract. The gauge contract is responsible for distributing CRV rewards to the metapool LPs. This function allows the factory owner or the Idle governance to upgrade or migrate the gauge contract to a new implementation.
// set_views_implementation: sets the implementation contract address for the views contract. The views contract provides some helper functions for querying information about the metapool, such as the balances, the rates, the fees, and the prices. This function allows the factory owner or the Idle governance to upgrade or migrate the views contract to a new implementation.
// set_math_implementation: sets the implementation contract address for the math contract. The math contract contains some low-level mathematical functions that are used by the metapool, such as the curve invariant calculation, the price calculation, and the fee calculation. This function allows the factory owner or the Idle governance to upgrade or migrate the math contract to a new implementation.
