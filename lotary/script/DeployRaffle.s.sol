// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { Raffle } from "../src/Raffle.sol";
import { HelperConfig } from "./HelperConfig.s.sol";
import { CreateSubscription, FundSubscription, AddConsumer} from "./Iteractions.s.sol";

contract DeployRaffle is Script {

	function run() external returns(Raffle, HelperConfig) {
		return deployContract();
	}

	function deployContract() public returns (Raffle, HelperConfig) {
		HelperConfig helperConfig = new HelperConfig();
		HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

		if (config.subscriptionId == 0) {
			CreateSubscription createSubscription = new CreateSubscription();
			config.subscriptionId = createSubscription.createSubscription(config.vrfCoordinator);

			FundSubscription fundSubscription = new FundSubscription();
			fundSubscription.fundSubscription(config.vrfCoordinator, config.subscriptionId, config.linkToken);
		}

		vm.startBroadcast();
		Raffle raffle = new Raffle(
			config.entranceFee,
			config.interval,
			config.vrfCoordinator,
			config.gasLane,
			config.subscriptionId,
			config.gasLimit
		);
		vm.stopBroadcast();
		
		AddConsumer addConsumer = new AddConsumer();
		addConsumer.addConsumer(address(raffle), config.vrfCoordinator, config.subscriptionId);

		return (raffle, helperConfig);
	}
}
