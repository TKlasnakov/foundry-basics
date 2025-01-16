// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { SimpleStorage } from "./SimpleStorage.sol";

contract StorageFactory {

SimpleStorage[] public listOfSimpleStorageContracts;

    function createSimpleStorageContract() public {
        listOfSimpleStorageContracts.push(new SimpleStorage());
    }

    function sfStore(uint256 _simpleStorageIndex, uint256 _simpleStorageNumber) public {
        listOfSimpleStorageContracts[_simpleStorageIndex].store(_simpleStorageNumber);
    }

    function sfGet(uint256 _contractIndex) public view returns (uint256 ){
        return listOfSimpleStorageContracts[_contractIndex].retrieve();
    }

		function getNumberOfSimpleStorageContracts() public view returns (uint256) {
				return listOfSimpleStorageContracts.length;
		}
}


