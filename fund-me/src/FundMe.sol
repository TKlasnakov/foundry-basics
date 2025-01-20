// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; 
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    address public  i_owner;
    uint256 public constant MINIMUM_USD = 5e18;
		AggregatorV3Interface public s_priceFeed; 


    constructor(address priceFeedAdress) {
        i_owner = msg.sender;
				s_priceFeed = AggregatorV3Interface(priceFeedAdress);
    }

    function fund() public payable {
      require(msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD, "You need to spend more ETH!");
      addressToAmountFunded[msg.sender] += msg.value;
      funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
			return s_priceFeed.version();
    }

    modifier onlyOwner() {
      if (msg.sender != i_owner) revert FundMe__NotOwner();
      _;
    }

    function withdraw() public onlyOwner {
      for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
				address funder = funders[funderIndex];
        addressToAmountFunded[funder] = 0;
      }
      funders = new address[](0);
      (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
      require(callSuccess, "Call failed");
    }

    fallback() external payable {
			fund();
    }

    receive() external payable {
			fund();
    }
}

