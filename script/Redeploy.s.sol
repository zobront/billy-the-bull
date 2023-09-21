// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script } from "forge-std/Script.sol";
import { BillyTheBull } from "../src/BillyTheBull.sol";

contract RedeployScript is Script {
    // update this based on last mint + 1e18
    // worst case i can make it block.timestamp * 1e12 and should work
    // i just don't want to undo everything to retest it
    uint NEXT_NFT_PRICE = 1200e18;
    address NFT_OUTLET = 0xf9F656435493C58421cFe153E5936f0FafF8c05f;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("CURTA_PK");

        vm.startBroadcast(deployerPrivateKey);

        BillyTheBull puzzle = new BillyTheBull{salt: keccak256(abi.encode(vm.addr(deployerPrivateKey)))}();
        puzzle.initialize(NFT_OUTLET, block.timestamp * 2e12);

        vm.stopBroadcast();
    }
}
