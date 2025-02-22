// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import { Script } from "forge-std/Script.sol";
import { VRFCoordinatorV2_5Mock } from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import { LinkToken } from "../test/mocks/LinkToken.sol";

abstract contract CodeConstants {
	uint256 public constant EHT_SEPOLIA_CHAIN_ID = 11155111;
	uint256 public constant LOCAL_CHAIN_ID = 31337;
	
	uint96 public MOCK_BASE_FEE = 0.25 ether;
	uint96 public MOCK_GAS_PRICE_LINK = 1e9;
	int256 public MOCK_WAI_PER_UNIT_LINK = 4e15;
}

contract HelperConfig is Script, CodeConstants {
	error HelperConfig__InvalidChainId();

	struct NetworkConfig {
		uint256 entranceFee;
		uint256 interval;
		address vrfCoordinator; 
		bytes32 gasLane; 
		uint256 subscriptionId;
		uint32 gasLimit;
		address linkToken;
	}

	NetworkConfig public localNetworkConfig;
	mapping(uint256 chainId => NetworkConfig) public networkConfigs;

	constructor() {
		networkConfigs[EHT_SEPOLIA_CHAIN_ID] = getSepoliaEthConfig();
	}

	function getConfigByChainId(uint256 chainId) private returns(NetworkConfig memory) {
		if(networkConfigs[chainId].vrfCoordinator != address(0)) {
			return networkConfigs[chainId];
		} else if (chainId == LOCAL_CHAIN_ID) {
			return getOrCreateAnvilConfig();
		} else {
			revert HelperConfig__InvalidChainId();
		}
	}

	function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
		return NetworkConfig({
			entranceFee: 0.001 ether,
			interval: 30,
			vrfCoordinator: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
			gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
			gasLimit: 500000,
			subscriptionId: 0,
			linkToken: 0x779877A7B0D9E8603169DdbD7836e478b4624789
		});
	}

	function getConfig() public returns(NetworkConfig memory){
		return getConfigByChainId(block.chainid);
	}

	function getOrCreateAnvilConfig() private returns(NetworkConfig memory) {
		if(localNetworkConfig.vrfCoordinator != address(0)) {
			return localNetworkConfig;
		}
		
		vm.startBroadcast();
		VRFCoordinatorV2_5Mock vrfCoordinatorMock = new VRFCoordinatorV2_5Mock(MOCK_BASE_FEE, MOCK_GAS_PRICE_LINK, MOCK_WAI_PER_UNIT_LINK);
		LinkToken linkToken = new LinkToken();
		vm.stopBroadcast();

		localNetworkConfig = NetworkConfig({
			entranceFee: 0.001 ether,
			interval: 30,
			vrfCoordinator: address(vrfCoordinatorMock),
			gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
			gasLimit: 500000,
			subscriptionId: 0,
			linkToken: address(linkToken)
		});

		return localNetworkConfig;
	}
}
