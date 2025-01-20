//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test } from "forge-std/Test.sol";
import { FundMe } from "../src/FundMe.sol";
import { DeployFundMe } from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
	FundMe fundMe;

	function setUp() external {
		DeployFundMe deployFundMe = new DeployFundMe();
		fundMe = deployFundMe.run();
	}

	function testMinimalDollarIsFive() public view {
		assertEq(fundMe.MINIMUM_USD(), 5e18);
	}

	function testAddress() public view {
		
	}
}
