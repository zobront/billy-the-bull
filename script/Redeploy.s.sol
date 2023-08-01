// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script } from "forge-std/Script.sol";
import { DeploymentHelpers } from "./DeploymentHelpers.sol";

contract DeployScript is DeploymentHelpers, Script {
    uint NEXT_NFT_PRICE = 1000e18; // update this based on last mint + 1e18

    function run() public {
        vm.startBroadcast();
        redeployPuzzle(address(nftOutlet), NEXT_NFT_PRICE);
        vm.stopBroadcast();
    }
}
