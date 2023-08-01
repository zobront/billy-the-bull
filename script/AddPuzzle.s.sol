// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script } from "forge-std/Script.sol";

interface Curta {
    function addPuzzle(address, uint256) external;
}

interface Authorship {
    function balanceOf(address) external view returns (uint256);
}

contract AddPuzzleScript is Script {
    Curta CURTA = Curta(0x0000000006bC8D9e5e9d436217B88De704a9F307);
    Authorship AUTHORSHIP = Authorship(0xC0ffeEb30F5aAA18Cd0a799F6dA1bdcb46f63C44);
    address PUZZLE = address(0);
    uint AUTHORSHIP_TOKEN_ID = 0;

    function run() public {
        uint balance = AUTHORSHIP.balanceOf(address(this)); // make sure this is the caller?
        assert(balance == 1);

        vm.startBroadcast();
        CURTA.addPuzzle(PUZZLE, AUTHORSHIP_TOKEN_ID);
        vm.stopBroadcast();
    }
}
