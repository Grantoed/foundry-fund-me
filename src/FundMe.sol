// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe_NotOwner();
error FundMe_MustBeMoreThan5USD();
error FundMe_CallFailed();

contract FundMe {
    using PriceConverter for uint256;

    address private immutable i_owner;
    address[] private s_funders;
    AggregatorV3Interface private s_priceFeed;

    uint256 public constant MIN_USD = 5 * 1e18;

    mapping(address funder => uint256 amountFunded)
        private s_funderToAmountFunded;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        if (msg.value.getConversionRateInUsd(s_priceFeed) <= MIN_USD) {
            revert FundMe_MustBeMoreThan5USD();
        }
        s_funders.push(msg.sender);
        s_funderToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;

        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_funderToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!callSuccess) {
            revert FundMe_CallFailed();
        }
    }

    function getPeople() public view returns (address[] memory) {
        return s_funders;
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getAmoundFundedByFunder(
        address funder
    ) external view returns (uint256) {
        return s_funderToAmountFunded[funder];
    }

    modifier onlyOwner() {
        if (i_owner != msg.sender) {
            revert FundMe_NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
