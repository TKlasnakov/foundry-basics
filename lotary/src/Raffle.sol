// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


/**
* @title Raffle
* @dev Implement Chainlink VRF
* @author Todor Klasnakov
* @notice Create a simple Raffle
*/
contract Raffle {
	uint256 private immutable i_entraceFee;
	error Raffle__SendMoreToEnterRaffle();

	constructor (uint256 _entraceFee) {
		i_entraceFee = _entraceFee;
	}

	function enterRaffle() external payable {
		if (msg.value < i_entraceFee) {
			revert Raffle__SendMoreToEnterRaffle();
		}
	}	

	function pickWinner() public {}


	function getEntranceFee() external view returns (uint256) {
		return i_entraceFee;
	}
}
