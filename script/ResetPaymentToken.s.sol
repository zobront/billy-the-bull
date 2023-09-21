// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script } from "forge-std/Script.sol";
import { NFTOutlet } from "../src/NFTOutlet.sol";

contract ResetPaymentTokenScript is Script {
    NFTOutlet NFT_OUTLET = NFTOutlet(0xf9F656435493C58421cFe153E5936f0FafF8c05f); // update
    address DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("CURTA_PK");
        vm.startBroadcast(deployerPrivateKey);
        NFT_OUTLET.changePaymentToken(DAI);
        vm.stopBroadcast();
    }
}
