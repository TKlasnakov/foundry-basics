// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { MockV3Aggregator } from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {

	NetworkConfig public activeConfig;

	uint8 public constant DECIMALS = 8;
	int256 public constant INITIAL_PRICE = 2000e8;

	struct NetworkConfig {
		address priceFeedAdress;
	}

	constructor() {
		if (block.chainid == 11155111) {
			activeConfig = getSepoliaEthConfig();
		} else {
			activeConfig = getAnvilEthConfig();
		}
	}

	function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
		NetworkConfig memory sepoliaConfig = NetworkConfig({
			priceFeedAdress: 0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
		});	

		return sepoliaConfig;
	}

	function getAnvilEthConfig() public returns (NetworkConfig memory) {
		if(activeConfig.priceFeedAdress != address(0)) {
			return activeConfig;
		}


		vm.startBroadcast();
		MockV3Aggregator priceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
		vm.stopBroadcast();


		NetworkConfig memory anvilConfig = NetworkConfig({
			priceFeedAdress: address(priceFeed)
		});

		return anvilConfig;
	}
}
