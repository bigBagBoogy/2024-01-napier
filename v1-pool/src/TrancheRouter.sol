// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

// interfaces
import {IWETH9} from "./interfaces/external/IWETH9.sol";
import {IERC20} from "@openzeppelin/contracts@4.9.3/token/ERC20/IERC20.sol";
import {ITrancheFactory} from "@napier/napier-v1/src/interfaces/ITrancheFactory.sol";
import {ITranche} from "@napier/napier-v1/src/interfaces/ITranche.sol";
import {ITrancheRouter} from "./interfaces/ITrancheRouter.sol";
// libraries
import {SafeERC20} from "@openzeppelin/contracts@4.9.3/token/ERC20/utils/SafeERC20.sol";
import {TrancheAddress} from "./libs/TrancheAddress.sol";
// inherits
import {PeripheryImmutableState} from "./base/PeripheryImmutableState.sol";
import {PeripheryPayments} from "./base/PeripheryPayments.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts@4.9.3/security/ReentrancyGuard.sol";
import {Multicallable} from "./base/Multicallable.sol";

/// @notice Periphery contract for interacting with Tranches.
/// @dev Accept native ETH and ERC20 tokens.
/// @dev Multicallable is used to batch calls to `unwrapWETH9`.
contract TrancheRouter is ITrancheRouter, PeripheryPayments, ReentrancyGuard, Multicallable {
    using SafeERC20 for IERC20;

    /// @dev Tranches called by this router must be created by this factory
    ITrancheFactory public immutable trancheFactory;

    bytes32 internal immutable TRANCHE_CREATION_HASH;

    constructor(ITrancheFactory _trancheFactory, IWETH9 _WETH9) PeripheryImmutableState(_WETH9) {
        trancheFactory = _trancheFactory;
        TRANCHE_CREATION_HASH = _trancheFactory.TRANCHE_CREATION_HASH();
    }

    /// @notice deposit an `underlyingAmount` of underlying token into the yield source, receiving PT and YT. principal token yield token
    /// @dev Accept native ETH.
    /// @inheritdoc ITrancheRouter
    function issue(address adapter, uint256 maturity, uint256 underlyingAmount, address to)
        external
        payable
        nonReentrant
        returns (uint256)
    {
        ITranche tranche =
            TrancheAddress.computeAddress(adapter, maturity, TRANCHE_CREATION_HASH, address(trancheFactory));
        IERC20 underlying = IERC20(tranche.underlying());

        // Transfer underlying tokens to this contract
        // If this contract holds enough ETH, wrap it. Otherwise, transfer from the caller.
        if (address(underlying) == address(WETH9) && address(this).balance >= underlyingAmount) {
            WETH9.deposit{value: underlyingAmount}();
        } else {
            underlying.safeTransferFrom(msg.sender, address(this), underlyingAmount);
        }
        // Force approve
        underlying.forceApprove(address(tranche), underlyingAmount);

        return tranche.issue(to, underlyingAmount);
    }

    /// @notice Withdraws underlying tokens from the caller in exchange for `pyAmount` of PT and YT.
    /// @notice Approve this contract to spend `pyAmount` of PT.
    /// @dev If caller want to withdraw ETH, specify `to` as the this contract's address and use `unwrapWETH9` with Multicall.
    /// @inheritdoc ITrancheRouter
    function redeemWithYT(address adapter, uint256 maturity, uint256 pyAmount, address to)
        external
        nonReentrant
        returns (uint256)
    {
        ITranche tranche =
            TrancheAddress.computeAddress(adapter, maturity, TRANCHE_CREATION_HASH, address(trancheFactory));
        return tranche.redeemWithYT({from: msg.sender, to: to, pyAmount: pyAmount});
    }

    /// @notice Approve this contract to spend `principalAmount` of PT.
    /// @dev If caller want to withdraw ETH, specify `to` as the this contract's address and use `unwrapWETH9` with Multicall.
    /// @inheritdoc ITrancheRouter
    function redeem(address adapter, uint256 maturity, uint256 principalAmount, address to)
        external
        nonReentrant
        returns (uint256)
    {
        ITranche tranche =
            TrancheAddress.computeAddress(adapter, maturity, TRANCHE_CREATION_HASH, address(trancheFactory));
        return tranche.redeem({from: msg.sender, to: to, principalAmount: principalAmount});
    }

    /// @notice Approve this contract to spend `principalAmount` of PT.
    /// @dev If caller want to withdraw ETH, specify `to` as the this contract's address and use `unwrapWETH9` with Multicall.
    /// @inheritdoc ITrancheRouter
    function withdraw(address adapter, uint256 maturity, uint256 underlyingAmount, address to)
        external
        nonReentrant
        returns (uint256)
    {
        ITranche tranche =
            TrancheAddress.computeAddress(adapter, maturity, TRANCHE_CREATION_HASH, address(trancheFactory));
        return tranche.withdraw({from: msg.sender, to: to, underlyingAmount: underlyingAmount});
    }
}
// This contract is a TrancheRouter, which is a periphery contract for interacting with Tranches1. Tranches are contracts that allow users to deposit an underlying token (such as ETH or ERC20) into a yield source (such as Aave or Compound) and receive two tokens in return: a principal token (PT) and a yield token (YT)2. The PT represents the initial deposit and the YT represents the interest earned over time. Users can redeem their PT and YT for the underlying token at any time, or trade them on secondary markets.

// The TrancheRouter contract inherits from several base contracts that provide useful functionalities, such as:

// PeripheryPayments: allows the contract to accept and send ETH or ERC20 tokens.
// ReentrancyGuard: prevents reentrancy attacks by using a lock mechanism.
// Multicallable: allows the contract to batch multiple function calls in one transaction.
// The TrancheRouter contract also uses some external interfaces and libraries, such as:

// IWETH9: an interface for the canonical Wrapped Ether (WETH) contract, which is an ERC20 token that wraps ETH.
// IERC20: an interface for the standard ERC20 token contract.
// ITrancheFactory: an interface for the TrancheFactory contract, which is responsible for creating and managing Tranches.
// ITranche: an interface for the Tranche contract, which implements the core logic of depositing, issuing, redeeming, and burning PT and YT.
// ITrancheRouter: an interface for the TrancheRouter contract itself, which defines the external functions that users can call.
// SafeERC20: a library that provides safe methods for interacting with ERC20 tokens, such as checking the return value of transfer and approve.
// TrancheAddress: a library that computes the address of a Tranche given its adapter, maturity, and creation code.
// The TrancheRouter contract has two main functions that users can call to interact with Tranches:

// issue: allows users to deposit an underlyingAmount of underlying token into the yield source, receiving PT and YT in return. The function accepts native ETH and converts it to WETH if necessary. The function also requires the user to specify the adapter (the address of the yield source adapter contract), the maturity (the timestamp when the Tranche matures), and the to (the recipient of the PT and YT). The function also allows the user to set minimum amounts for the PT and YT to prevent slippage. The function returns the actual amounts of PT and YT issued.

// redeemWithYT: allows users to withdraw underlying tokens from the yield source in exchange for pyAmount of PT and YT. The function requires the user to approve the contract to spend their PT and YT. The function also requires the user to specify the adapter, the maturity, and the to (the recipient of the underlying tokens). The function returns the amount of underlying tokens redeemed.

//redeem: allows users to withdraw underlying tokens from the yield source in exchange for principalAmount of PT only. The function does not require the user to provide any YT, but it will burn the equivalent amount of YT from the pool. The function returns the amount of underlying tokens redeemed.

// withdraw: allows users to withdraw a specific underlyingAmount of underlying tokens from the yield source by burning the corresponding amount of PT and YT. The function returns the amount of PT and YT burned.

// Both functions require the user to approve the contract to spend their PT, and they also require the user to specify the adapter, the maturity, and the to (the recipient of the underlying tokens). If the user wants to withdraw ETH, they need to set the to as the contract’s address and use the unwrapWETH9 function with Multicall to convert the WETH to ETH.
