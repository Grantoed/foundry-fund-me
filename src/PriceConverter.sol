// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    function getPrice(
        AggregatorV3Interface s_priceFeed
    ) internal view returns (uint256) {
        (, int256 answer, , , ) = s_priceFeed.latestRoundData();

        return uint256(answer) * 1e10;
    }

    function getConversionRateInUsd(
        uint256 ethAmount,
        AggregatorV3Interface s_priceFeed
    ) internal view returns (uint256) {
        uint256 ethPrice = getPrice(s_priceFeed);
        uint256 ethAmountInUsd = (ethAmount * ethPrice) / 1e18;

        return ethAmountInUsd;
    }
}
