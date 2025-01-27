// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

/**
* @title Raffle
* @dev Implement Chainlink VRF
* @author Todor Klasnakov
* @notice Create a simple Raffle
*/
contract Raffle is VRFConsumerBaseV2Plus {
	error Raffle__SendMoreToEnterRaffle();
	error Raffle__NotEnoughTimeHasPassed();
	error Raffle__MoneyNotSent();
	error Raffle__UpkeepNotNeeded(uint256 balance, uint256 playersLength, uint256 raffleState);

	enum RaffleState {
		OPEN,
		CALCULATING_WINNER
	}
	
	uint8 private constant REQUEST_CONFIRMATIONS = 3;
	uint8 private constant NUM_WORDS = 1;
	uint256 private immutable i_entraceFee;
	uint256 private immutable i_interval;
	uint256 private immutable i_subscriptionId;
	uint32 private immutable i_callbackGasLimit;
	bytes32 private immutable i_keyHash;
	uint256 private s_lastTimeStamp;
	address payable[] private s_players;
	address private s_recentWinner;
	RaffleState private s_raffleState;

	event RaffleEntered(address indexed player);
	event WinnerPicked(address s_recentWinner);

	constructor (uint256 _entraceFee, 
							 uint256 _interval, 
							 address _vrfCoordinator, 
							 bytes32 _gasLane, 
							 uint256 _subscriptionId, 
							 uint32 _gasLimit) 
	VRFConsumerBaseV2Plus(_vrfCoordinator) {
		i_entraceFee = _entraceFee;
		i_interval = _interval;
		s_lastTimeStamp = block.timestamp;
		i_keyHash = _gasLane;
		i_subscriptionId = _subscriptionId;
		i_callbackGasLimit = _gasLimit;
		s_raffleState = RaffleState.OPEN;
	}

	function enterRaffle() external payable {
		if (msg.value < i_entraceFee) {
			revert Raffle__SendMoreToEnterRaffle();
		}

		if(s_raffleState != RaffleState.OPEN) {
			revert Raffle__UpkeepNotNeeded(address(this).balance, s_players.length, uint256(s_raffleState));
		}

		s_players.push(payable(msg.sender));
		emit RaffleEntered(msg.sender);
	}	

	function checkUpkeep(bytes memory /* checkData */) public view 
	returns (bool upkeepNeeded, bytes memory /* performData */) {
		bool timeHasPassed = block.timestamp - s_lastTimeStamp >= i_interval; 
		bool isOpen = s_raffleState == RaffleState.OPEN;
		bool hasBalance = address(this).balance > 0;
		bool hasPlayers = s_players.length > 0;

		upkeepNeeded = timeHasPassed && isOpen && hasBalance && hasPlayers;

		return (upkeepNeeded, "");
  }

	function performUpkeep(bytes calldata /* performData */) external {
		(bool upkeepNeeded,) = checkUpkeep("");
		if(!upkeepNeeded) {
			revert Raffle__NotEnoughTimeHasPassed();
		}

		s_raffleState = RaffleState.CALCULATING_WINNER;

		uint256 requestId = getRandomNumber();
	}

	function getEntranceFee() external view returns (uint256) {
		return i_entraceFee;
	}

	function getRandomNumber() private returns (uint256) {
		return s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_keyHash,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: false}))
            })
        );
	}

	function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
		uint256 playersLength = s_players.length;
		uint256 winnerIndex = randomWords[0] % playersLength;
		address payable recentWinner = s_players[winnerIndex];

		s_recentWinner = recentWinner;
		s_raffleState = RaffleState.OPEN;
		s_players = new address payable[](0);
		s_lastTimeStamp = block.timestamp;

		(bool success, ) = recentWinner.call{value: address(this).balance}("");

		if (!success) {
			revert Raffle__MoneyNotSent();
		}

		emit WinnerPicked(s_recentWinner);
	}
}
