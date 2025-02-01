// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Test, console } from "forge-std/Test.sol";
import { DeployRaffle } from "../../script/DeployRaffle.s.sol";
import { HelperConfig } from "../../script/HelperConfig.s.sol";
import { Raffle } from "../../src/Raffle.sol";
import { Vm } from "forge-std/Vm.sol";

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

	event RaffleEntered(address indexed player);
	event WinnerPicked(address s_recentWinner);

	modifier raffleEntered() {
		vm.prank(PLAYER);
		raffle.enterRaffle{value: entranceFee}();
		vm.warp(block.timestamp + interval + 1);
		vm.roll(block.number + 1);
		_;
	}

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

	function testEntaringRaffleEmitsEvent() public {
		vm.prank(PLAYER);

		vm.expectEmit(true, false, false, false, address(raffle));
		emit RaffleEntered(PLAYER);

		raffle.enterRaffle{value: entranceFee}();
	}

	function testDontAllowPlayersToEnterWhileRaffleIsCalculating() public raffleEntered {
		raffle.performUpkeep("");

		vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
		raffle.enterRaffle{value: entranceFee}();
	}

	function testCheckUpkeepReturnsFalseIfHasNoBalance() public {
		vm.warp(block.timestamp + interval + 1);
		vm.roll(block.number + 1);
		(bool upkeepNeeded, ) = raffle.checkUpkeep("");

		assert(!upkeepNeeded);
	}

	function testCheckUpkeepReturnsFalseIfRaffleNotOpen() public raffleEntered{
		raffle.performUpkeep("");

		(bool upkeepNeeded, ) = raffle.checkUpkeep("");
		assert(!upkeepNeeded);
	}

	function testIsCheckUpkeepCalledCorrectly() public raffleEntered {
		(bool upkeepNeeded, ) = raffle.checkUpkeep("");

		assert(upkeepNeeded == true);
	}

	function testPerformUpkeepTriggeredOnlyWhenCheckUpkeepIsTrue() public raffleEntered {
		raffle.performUpkeep("");
		
		vm.expectRevert(Raffle.Raffle__NotEnoughTimeHasPassed.selector);
		raffle.performUpkeep("");
	}

	function testPerformUpkeepUpdateRaffle() public raffleEntered {
		vm.recordLogs();
		raffle.performUpkeep("");

		Raffle.RaffleState raffleState = raffle.getRaffleState();
		assert(raffleState == Raffle.RaffleState.CALCULATING_WINNER);
	}
}
