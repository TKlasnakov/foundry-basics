//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Test } from "forge-std/Test.sol";
import { FundMe } from "../src/FundMe.sol";
import { DeployFundMe } from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
	FundMe fundMe;
	address USER = makeAddr("user");
	uint256 constant SEND_VALUE = 0.1 ether;
	uint256 constant START_BALANCE = 1 ether;

	function setUp() external {
		DeployFundMe deployFundMe = new DeployFundMe();
		fundMe = deployFundMe.run();
		vm.deal(USER, START_BALANCE);
	}

	function testMinimalDollarIsFive() public view {
		assertEq(fundMe.MINIMUM_USD(), 5e18);
	}

	function testOwnerIsMessenger() public view {
		assertEq(fundMe.getOwner(), msg.sender);
	}

	function testVersionIsZero() public view {
		assertEq(fundMe.getVersion(), 4);
	}

	function testNotEnoughEth() public {
		vm.expectRevert();

		fundMe.fund();
	}

	function testEnoughEth() public {
		vm.prank(USER);
		fundMe.fund{value: SEND_VALUE}();
		assertEq(fundMe.getAddressesToAmountFunded(USER), SEND_VALUE);
	}

	modifier funded() {
		vm.prank(USER);
		fundMe.fund{value: SEND_VALUE}();
		_;
	}

	function testAddsFundersToArray() public funded {
		assertEq(fundMe.getFunders(0), USER);
	}

	function testWithdrawOnlyOwnerRevert() public funded {
		vm.expectRevert();
		fundMe.withdraw();
	}

	function testWithdraw() public funded {
		uint256 startingOwnerBalance = fundMe.getOwner().balance;
		uint256 startingFundMeBalance = address(fundMe).balance;

		vm.prank(fundMe.getOwner());
		fundMe.withdraw();

		uint256 endingOwnerBalance = fundMe.getOwner().balance;
		uint256 endingFundMeBalance = address(fundMe).balance;

		assertEq(endingFundMeBalance, 0);
		assertEq(startingOwnerBalance + startingFundMeBalance, endingOwnerBalance);
	}
}
