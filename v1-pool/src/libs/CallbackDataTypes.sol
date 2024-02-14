// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.10;

import {IERC20} from "@openzeppelin/contracts@4.9.3/token/ERC20/IERC20.sol";
import {ITranche} from "@napier/napier-v1/src/interfaces/ITranche.sol";

enum CallbackType {
    SwapPtForUnderlying, // Swapping principal tokens (PT) for underlying tokens.
    SwapUnderlyingForPt, // Swapping underlying tokens for principal tokens.
    SwapYtForUnderlying, // Swapping Yield Tokens (YT) for underlying tokens.
    SwapUnderlyingForYt, // Swapping underlying tokens for Yield Tokens.
    AddLiquidityPts, // Adding liquidity using principal tokens.
    AddLiquidityOnePt, // Adding liquidity with a single principal token.
    AddLiquidityOneUnderlying // Adding liquidity with a single underlying token.
}

library CallbackDataTypes {
    // This internal function extracts the callback type from the provided calldata.
    // It reads the first 32 bytes of the calldata (using assembly) and returns the corresponding CallbackType.
    function getCallbackType(bytes calldata data) internal pure returns (CallbackType callbackType) {
        // Read the first 32 bytes of the calldata
        assembly {
            callbackType := calldataload(data.offset)
        }
    }
    //  Contains information related to adding liquidity, including the payer’s address, underlying token, and base pool.

    struct AddLiquidityData {
        address payer;
        address underlying;
        address basePool;
    }
    // Holds details for swapping principal tokens for underlying tokens, including the payer’s address and the principal token (PT).

    struct SwapPtForUnderlyingData {
        address payer;
        IERC20 pt;
    }
    // Specifies the payer’s address and the maximum amount of underlying tokens to swap for principal tokens.

    struct SwapUnderlyingForPtData {
        address payer;
        uint256 underlyingInMax;
    }
    // Describes the process of swapping yield tokens (YT) for underlying tokens, including the payer, yield token (YT), recipient, and minimum underlying output.

    struct SwapYtForUnderlyingData {
        address payer;
        ITranche pt;
        uint256 ytIn;
        address recipient;
        uint256 underlyingOutMin;
    }
    // Represents the swap of underlying tokens for yield tokens, considering the payer, yield token (YT), recipient, underlying deposit, and maximum underlying pull.

    struct SwapUnderlyingForYtData {
        address payer;
        ITranche pt;
        IERC20 yt;
        address recipient;
        uint256 underlyingDeposit;
        uint256 maxUnderlyingPull;
    }
}
