// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test } from "forge-std/Test.sol";
import { DeployRaffle } from "../../script/DeployRaffle.s.sol";
import { HelperConfig } from "../../script/HelperConfig.s.sol";
import { Raffle } from "../../src/Raffle.sol";

contract RaffleTest is Test {
	Raffle public raffle;
	HelperConfig public helperConfig;

	uint256 entranceFee;
	uint256 interval;
	address vrfCoordinator; 
	bytes32 gasLane; 
	uint256 subscriptionId;
	uint32 gasLimit;

	address public PLAYER = makeAddr("player");
	uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

	function setUp() public {
		DeployRaffle deployer = new DeployRaffle();
		(raffle, helperConfig) = deployer.deployContract();
		HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
		entranceFee = config.entranceFee;
		interval = config.interval;
		vrfCoordinator = config.vrfCoordinator;
		gasLane = config.gasLane;
		subscriptionId = config.subscriptionId;
		gasLimit = config.gasLimit;


		vm.deal(PLAYER, STARTING_PLAYER_BALANCE);
	}

	function testRaffleInitializeInOpenState() public view {
		assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
	}

	function testRaffleRevertIfNotEnoughIsPaid() public {
		vm.prank(PLAYER);
		vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
		raffle.enterRaffle();	
	}
	
	function testPlayerAddedAfterPayingCorrectPrice() public {
		vm.prank(PLAYER);
		raffle.enterRaffle{value: entranceFee}();
		assert(raffle.getPlayer(0) == address(PLAYER));
	}

}
