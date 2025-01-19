//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test } from "forge-std/Test.sol";
import { FundMe } from "../src/FundMe.sol";

contract FundMeTest is Test {
	FundMe fundMe;

	function setup() external {
		fundMe = new FundMe();
	}

	function testMinimalDollarIsFive() public view {
		assertEq(fundMe.MINIMUM_USD(), 5e18);
	}
}
