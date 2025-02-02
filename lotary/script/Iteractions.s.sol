// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script, console } from "forge-std/Script.sol";
import { HelperConfig, CodeConstants } from "./HelperConfig.s.sol";
import { VRFCoordinatorV2_5Mock } from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import { LinkToken } from "../test/mocks/LinkToken.sol";

contract CreateSubscription is Script {

	function createSubscriptionUsingConfig() public returns(uint256, address){
		HelperConfig helperconfig = new HelperConfig();
		address vrfCoordinator = helperconfig.getConfig().vrfCoordinator;
	  uint256 subId = createSubscription(vrfCoordinator);

		return (subId, vrfCoordinator);
	}

	function createSubscription(address vrfCoordinator) public returns (uint256) {
		console.log("Create subscription on chain id: ", block.chainid);
		vm.startBroadcast();
		uint256 subId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();
		vm.stopBroadcast();

		console.log("Your subscription id is: ", subId);
		console.log("Please update the subscription Id in your HelperConfig.s.sol");

		return subId;
	}

	function run() public {
		createSubscriptionUsingConfig();
	}
}

contract FundSubscription is Script, CodeConstants {
	uint256 public constant FUND_AMOUNT = 3 ether;

	function fundSubscriptionConfig() public {
		HelperConfig helperconfig = new HelperConfig();
		address vrfcoordinator = helperconfig.getConfig().vrfCoordinator;
		uint256 subscriptionId = helperconfig.getConfig().subscriptionId;
		address linkToken = helperconfig.getConfig().linkToken;
		fundSubscription(vrfcoordinator, subscriptionId, linkToken);
	}

	function fundSubscription(address vrfCoordinator, uint256 subscriptionId, address linkToken) public {
		if (block.chainid == LOCAL_CHAIN_ID) {
			vm.startBroadcast();
			VRFCoordinatorV2_5Mock(vrfCoordinator).fundSubscription(subscriptionId, FUND_AMOUNT);
			vm.stopBroadcast();
		} else {
			vm.startBroadcast();
			LinkToken(linkToken).transferAndCall(vrfCoordinator, FUND_AMOUNT, abi.encode(subscriptionId));
			vm.stopBroadcast();
		} 
	}

	function run() public {
		fundSubscriptionConfig();
	}
}

contract AddConsumer is Script() {
	function addConsumerUsingConfig(address deployedContract) public {
		HelperConfig helperConfig = new HelperConfig();
		uint256 subId = helperConfig.getConfig().subscriptionId;
		address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
		addConsumer(deployedContract, vrfCoordinator, subId);
	}

	function addConsumer(address contractAddress, address vrfCoordinator, uint256 subId) public {
		vm.startBroadcast();
		VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(subId, contractAddress);
		vm.stopBroadcast();
	}

	function run() public {}
}
