// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script } from "forge-std/Script.sol";
import { DeploymentHelpers } from "./DeploymentHelpers.sol";

contract ResetPaymentTokenScript is DeploymentHelpers, Script {
    function run() public {
        vm.startBroadcast();
        resetPaymentToken();
        vm.stopBroadcast();
    }
}
