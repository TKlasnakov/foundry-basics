//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { FundMe } from "../src/FundMe.sol";
import { HelperConfig } from "./HelperConfig.s.sol";

contract DeployFundMe is Script {

	HelperConfig config = new HelperConfig();

	function run() external returns (FundMe){
		vm.startBroadcast();
		FundMe fundMe = new FundMe(config.activeConfig());
		vm.stopBroadcast();

		return fundMe;
	}
}
