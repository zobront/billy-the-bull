// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script } from "forge-std/Script.sol";
import { BillyTheBullManager } from "./BillyTheBullManager.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();
        deployAllContracts();
        vm.stopBroadcast();
    }

    function deployAllContracts() public returns (address[] memory, address[] memory, address, address) {
        BillyTheBullManager manager = new BillyTheBullManager();
        return manager.deploy();
    }
}
