// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;
// This interface is a set of functions that allow users to query the prices and amounts for token swaps and liquidity operations on NapierSwap pools, which are smart contracts that enable swapping tokens between different interest rates and leverage levels.
// I know there is only (0, 1, or 2) in the index of the Principal token because I searched the web for information about Principal tokens and NapierSwap. I found out that NapierSwap is a protocol that allows users to swap tokens between different interest rates and leverage levels¹². NapierSwap uses Principal tokens (PT) and Yield tokens (YT) to represent the user's position in a pool¹. A pool is a smart contract that contains an underlying token and a base pool LP token¹. A pool can have up to three Principal tokens, each corresponding to a different leverage level (0%, 50%, or 100%)¹. Therefore, the index of the Principal token can only be 0, 1, or 2, depending on the leverage level chosen by the user. The index is used to identify and access the Principal token in the pool contract³.

// Source: Conversation with Bing, 2/15/2024
// (1) Unveiling Napier Protocol — Evolving Curve For Yield Trading. https://medium.com/napier-finance/unveiling-napier-protocol-evolving-curve-for-yield-trading-c00a357148e6.
// (2) Napier Finance | ETHGlobal. https://ethglobal.com/showcase/napier-finance-suazx.
// (3) ERC-5095: Principal Token - Ethereum Improvement Proposals. https://eips.ethereum.org/EIPS/eip-5095.

import {IPoolFactory} from "../interfaces/IPoolFactory.sol";
import {INapierPool} from "../interfaces/INapierPool.sol";

/// @title An interface for quoting prices and amounts for NapierSwap pools
/// @notice This interface provides functions to query the prices and amounts for token swaps and liquidity operations on NapierSwap pools
/// @dev NapierSwap is a protocol that allows users to swap tokens between different interest rates and leverage levels
interface IQuoter {
    /// @notice Get the underlying token and the base pool LP token of a NapierSwap pool
    /// @param pool The address of the NapierSwap pool
    /// @return assets A struct containing the underlying token and the base pool LP token
    function getPoolAssets(INapierPool pool) external view returns (IPoolFactory.PoolAssets memory assets);

    /////////////////// Price ///////////////////

    /// @notice Get the price of the base pool LP token in terms of the underlying token
    /// @param pool The address of the NapierSwap pool
    /// @return The price of the base pool LP token
    function quoteBasePoolLpPrice(INapierPool pool) external view returns (uint256);

    /// @notice Get the price of the Principal token in terms of the underlying token
    /// @param pool The address of the NapierSwap pool
    /// @param index The index of the Principal token (0, 1, or 2)
    /// @return The price of the Principal token
    function quotePtPrice(INapierPool pool, uint256 index) external view returns (uint256);

    /////////////////// Quote for swap ///////////////////

    /// @notice Get the amount of underlying token that can be obtained by swapping a given amount of Principal token
    /// @param pool The address of the NapierSwap pool
    /// @param index The index of the Principal token (0, 1, or 2)
    /// @param ptIn The amount of Principal token to swap
    /// @return underlyingOut The amount of underlying token that can be obtained
    /// @return gasEstimate The estimated gas cost of the swap
    function quotePtForUnderlying(INapierPool pool, uint256 index, uint256 ptIn)
        external
        returns (uint256 underlyingOut, uint256 gasEstimate);

    /// @notice Get the amount of underlying token that needs to be provided to swap for a given amount of Principal token
    /// @param pool The address of the NapierSwap pool
    /// @param index The index of the Principal token (0, 1, or 2)
    /// @param ptOutDesired The amount of Principal token desired
    /// @return underlyingIn The amount of underlying token that needs to be provided
    /// @return gasEstimate The estimated gas cost of the swap
    function quoteUnderlyingForPt(INapierPool pool, uint256 index, uint256 ptOutDesired)
        external
        returns (uint256 underlyingIn, uint256 gasEstimate);

    /// @notice Get the amount of underlying token that can be obtained by swapping a given amount of Yield token
    /// @param pool The address of the NapierSwap pool
    /// @param index The index of the Yield token (0, 1, or 2)
    /// @param ytIn The amount of Yield token to swap
    /// @return underlyingOut The amount of underlying token that can be obtained
    /// @return gasEstimate The estimated gas cost of the swap
    function quoteYtForUnderlying(INapierPool pool, uint256 index, uint256 ytIn)
        external
        returns (uint256 underlyingOut, uint256 gasEstimate);

    /// @notice Get the amount of underlying token that needs to be provided to swap for a given amount of Yield token
    /// @param pool The address of the NapierSwap pool
    /// @param index The index of the Yield token (0, 1, or 2)
    /// @param ytOut The amount of Yield token desired
    /// @return underlyingIn The amount of underlying token that needs to be provided
    /// @return gasEstimate The estimated gas cost of the swap
    function quoteUnderlyingForYt(INapierPool pool, uint256 index, uint256 ytOut)
        external
        returns (uint256 underlyingIn, uint256 gasEstimate);

    /////////////////////////////////////////////////////////////////////////////////////
    // Quote for Liquidity provision / removal
    /////////////////////////////////////////////////////////////////////////////////////

    /// @notice Get the amount of liquidity that can be obtained by adding a given amount of underlying token and Principal tokens to a NapierSwap pool
    /// @param pool The address of the NapierSwap pool
    /// @param ptsIn An array of the amounts of Principal tokens to add
    /// @param underlyingIn The amount of underlying token to add
    /// @return liquidity The amount of liquidity that can be obtained
    /// @return gasEstimate The estimated gas cost of adding liquidity
    function quoteAddLiquidity(INapierPool pool, uint256[3] memory ptsIn, uint256 underlyingIn)
        external
        returns (uint256 liquidity, uint256 gasEstimate);

    /// @notice Get the amount of liquidity that can be obtained by adding a given amount of underlying token to a NapierSwap pool
    /// @param pool The address of the NapierSwap pool
    /// @param underlyingIn The amount of underlying token to add
    /// @return liquidity The amount of liquidity that can be obtained
    /// @return baseLptSwap The amount of base pool LP token that needs to be swapped for adding liquidity
    function quoteAddLiquidityOneUnderlying(INapierPool pool, uint256 underlyingIn)
        external
        view
        returns (uint256 liquidity, uint256 baseLptSwap);

    /// @notice Get the amount of liquidity that can be obtained by adding a given amount of Principal token to a NapierSwap pool
    /// @param pool The address of the NapierSwap pool
    /// @param index The index of the Principal token (0, 1, or 2)
    /// @param ptIn The amount of Principal token to add
    /// @return liquidity The amount of liquidity that can be obtained
    /// @return baseLptSwap The amount of base pool LP token that needs to be swapped for adding liquidity
    function quoteAddLiquidityOnePt(INapierPool pool, uint256 index, uint256 ptIn)
        external
        view
        returns (uint256 liquidity, uint256 baseLptSwap);

    /// @notice Get the amount of underlying token and base pool LP token that can be obtained by removing a given amount of liquidity from a NapierSwap pool
    /// @param pool The address of the NapierSwap pool
    /// @param liquidity The amount of liquidity to remove
    /// @return The amount of underlying token that can be obtained
    /// @return The amount of base pool LP token that can be obtained
    function quoteRemoveLiquidityBaseLpt(INapierPool pool, uint256 liquidity)
        external
        view
        returns (uint256, uint256);

    /// @notice Get the amount of underlying token and Principal tokens that can be obtained by removing a given amount of liquidity from a NapierSwap pool
    /// @param pool The address of the NapierSwap pool
    /// @param liquidity The amount of liquidity to remove
    /// @return The amount of underlying token that can be obtained
    /// @return An array of the amounts of Principal tokens that can be obtained
    function quoteRemoveLiquidity(INapierPool pool, uint256 liquidity)
        external
        view
        returns (uint256, uint256[3] memory);

    /// @notice Get the amount of underlying token, Principal token, and base pool LP token that can be obtained by removing a given amount of liquidity from a NapierSwap pool
    /// @param pool The address of the NapierSwap pool
    /// @param index The index of the Principal token (0, 1, or 2)
    /// @param liquidity The amount of liquidity to remove
    /// @return The amount of underlying token that can be obtained
    /// @return The amount of Principal token that can be obtained
    /// @return The amount of base pool LP token that can be obtained
    function quoteRemoveLiquidityOnePt(INapierPool pool, uint256 index, uint256 liquidity)
        external
        view
        returns (uint256, uint256, uint256);

    /// @notice Get the amount of underlying token that can be obtained by removing a given amount of liquidity from a NapierSwap pool
    /// @param pool The address of the NapierSwap pool
    /// @param index The index of the underlying token (0, 1, or 2)
    /// @param liquidity The amount of liquidity to remove
    /// @return underlyingOut The amount of underlying token that can be obtained
    /// @return gasEstimate The estimated gas cost of removing liquidity
    function quoteRemoveLiquidityOneUnderlying(INapierPool pool, uint256 index, uint256 liquidity)
        external
        view
        returns (uint256 underlyingOut, uint256 gasEstimate);

    /////////////////// Approximation ///////////////////

    /// @notice Get an approximate amount of Principal token that needs to be provided to swap for a given amount of underlying token
    /// @param pool The address of the NapierSwap pool
    /// @param index The index of the Principal token (0, 1, or 2)
    /// @param underlyingDesired The amount of underlying token desired
    /// @return The approximate amount of Principal token that needs to be provided
    function approxPtForExactUnderlyingOut(INapierPool pool, uint256 index, uint256 underlyingDesired)
        external
        view
        returns (uint256);

    /// @notice Get an approximate amount of Principal token that can be obtained by swapping a given amount of underlying token
    /// @param pool The address of the NapierSwap pool
    /// @param index The index of the Principal token (0, 1, or 2)
    /// @param underlyingDesired The amount of underlying token to swap
    /// @return The approximate amount of Principal token that can be obtained
    function approxPtForExactUnderlyingIn(INapierPool pool, uint256 index, uint256 underlyingDesired)
        external
        view
        returns (uint256);

    /// @notice Get an approximate amount of Yield token that needs to be provided to swap for a given amount of underlying token
    /// @param pool The address of the NapierSwap pool
    /// @param index The index of the Yield token (0, 1, or 2)
    /// @param underlyingDesired The amount of underlying token desired
    /// @return The approximate amount of Yield token that needs to be provided
    function approxYtForExactUnderlyingOut(INapierPool pool, uint256 index, uint256 underlyingDesired)
        external
        returns (uint256);

    /// @notice Get an approximate amount of Yield token that can be obtained by swapping a given amount of underlying token
    /// @param pool The address of the NapierSwap pool
    /// @param index The index of the Yield token (0, 1, or 2)
    /// @param underlyingDesired The amount of underlying token to swap
    /// @return The approximate amount of Yield token that can be obtained
    function approxYtForExactUnderlyingIn(INapierPool pool, uint256 index, uint256 underlyingDesired)
        external
        returns (uint256);

    /// @notice Get an approximate amount of base pool LP token that needs to be swapped to add a given amount of underlying token to a NapierSwap pool
    /// @param pool The address of the NapierSwap pool
    /// @param underlyingsToAdd The amount of underlying token to add
    /// @return The approximate amount of base pool LP token that needs to be swapped
    function approxBaseLptToAddLiquidityOneUnderlying(INapierPool pool, uint256 underlyingsToAdd)
        external
        view
        returns (uint256);

    /// @notice Get an approximate amount of base pool LP token that needs to be swapped to add a given amount of Principal token to a NapierSwap pool
    /// @param pool The address of the NapierSwap pool
    /// @param index The index of the Principal token (0, 1, or 2)
    /// @param ptToAdd The amount of Principal token to add
    /// @return The approximate amount of base pool LP token that needs to be swapped
    function approxBaseLptToAddLiquidityOnePt(INapierPool pool, uint256 index, uint256 ptToAdd)
        external
        view
        returns (uint256);

    /// @notice Get an approximate amount of base pool LP token that can be obtained by removing a given amount of liquidity from a NapierSwap pool
    /// @param pool The address of the NapierSwap pool
    /// @param liquidity The amount of liquidity to remove
    /// @return The approximate amount of base pool LP token that can be obtained
    function approxBaseLptToRemoveLiquidityOnePt(INapierPool pool, uint256 liquidity) external view returns (uint256);
}
