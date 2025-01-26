// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

/**
* @title Raffle
* @dev Implement Chainlink VRF
* @author Todor Klasnakov
* @notice Create a simple Raffle
*/
contract Raffle {
	error Raffle__SendMoreToEnterRaffle();
	error Raffle_NotEnoughTimeHasPassed();
	
	uint256 private immutable i_entraceFee;
	uint256 private immutable i_interval;
	uint256 private s_lastTimeStamp;
	address payable[] private s_players;

	event RaffleEntered(address indexed player);

	constructor (uint256 _entraceFee, uint256 _interval) {
		i_entraceFee = _entraceFee;
		i_interval = _interval;
		s_lastTimeStamp = block.timestamp;
	}

	function enterRaffle() external payable {
		if (msg.value < i_entraceFee) {
			revert Raffle__SendMoreToEnterRaffle();
		}

		s_players.push(payable(msg.sender));
		emit RaffleEntered(msg.sender);
	}	

	function pickWinner() external view {
		if(block.timestamp - s_lastTimeStamp < i_interval) {
			revert Raffle_NotEnoughTimeHasPassed();
		}
	}


	function getEntranceFee() external view returns (uint256) {
		return i_entraceFee;
	}

}
