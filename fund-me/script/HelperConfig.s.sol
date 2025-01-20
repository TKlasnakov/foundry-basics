// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";

contract HelperConfig is Script {

	struct NetworkConfig {
		address priceFeedAdress;
	}

	function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
			
	}

	function getAnvilEthConfig() public pure returns (NetworkConfig memory) {
			
	}
}
