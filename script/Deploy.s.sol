// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script } from "forge-std/Script.sol";
import { BillyTheBull } from "../src/BillyTheBull.sol";
import { Protocol } from "../src/Protocol.sol";
import { Stablecoin } from "../src/tokens/Stablecoin.sol";
import { NFT } from "../src/tokens/NFT.sol";
import { FreeNFT } from "../src/tokens/FreeNFT.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();
        deployAllContracts();
        vm.stopBroadcast();
    }

    function deployAllContracts() public returns (
        address[] memory stablecoins,
        address[] memory nfts,
        address puzzle,
        address protocol
    ) {
        (stablecoins, nfts) = _deployTokens();
        (puzzle, protocol) = _deployPuzzleAndProtocol(stablecoins, nfts);
    }

    function _deployTokens() internal returns (
        address[] memory stablecoins,
        address[] memory nfts
    ){
        stablecoins = new address[](3);
        nfts = new address[](3);

        stablecoins[0] = address(new Stablecoin("USDX", "USDX"));
        stablecoins[1] = address(new Stablecoin("USDY", "USDY"));
        stablecoins[2] = address(new Stablecoin("USDZ", "USDZ"));
        // stablecoins[0] = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI
        // stablecoins[1] = 0x853d955aCEf822Db058eb8505911ED77F175b99e; // FRAX
        // stablecoins[2] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC
        nfts[0] = address(new NFT("Bored Turtles", "BTYC"));
        nfts[1] = address(new NFT("Bored Sloths", "BSYC"));
        nfts[2] = address(new FreeNFT("Bored Warthogs", "BWYC"));
    }

    function _deployPuzzleAndProtocol(
        address[] memory stablecoins,
        address[] memory nfts
    ) internal returns (address, address) {
        BillyTheBull puzzle = new BillyTheBull(stablecoins, nfts);
        Protocol protocol = puzzle.protocol();
        return (address(puzzle), address(protocol));
    }

    // function _logAddresses(
    //     address wallet,
    //     address[] memory stablecoins,
    //     address[] memory nfts,
    //     address puzzle
    // ) internal {
    //     console.log("Wallet: ", wallet);
    //     for (uint i = 0; i < stablecoins.length; i++) {
    //         console.log("Stablecoin ", i, ": ", stablecoins[i]);
    //     }
    //     for (uint i = 0; i < nfts.length; i++) {
    //         console.log("NFT ", i, ": ", nfts[i]);
    //     }
    //     console.log("Puzzle: ", puzzle);
    // }
}