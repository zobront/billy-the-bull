// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script } from "forge-std/Script.sol";
import { BillyTheBull } from "../src/BillyTheBull.sol";
import { NFTOutlet } from "../src/NFTOutlet.sol";
import { Stablecoin } from "../src/tokens/Stablecoin.sol";
import { BoredTurtleYachtClub } from "../src/tokens/BoredTurtleYachtClub.sol";
import { BoredSlothYachtClub } from "../src/tokens/BoredSlothYachtClub.sol";

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
        address nftOutlet
    ) {
        (stablecoins, nfts) = _deployTokens();
        (puzzle, nftOutlet) = _deployPuzzleAndOutlet(stablecoins, nfts);
        BoredTurtleYachtClub(nfts[0]).initialize(nftOutlet);
    }

    function _deployTokens() internal returns (
        address[] memory stablecoins,
        address[] memory nfts
    ){
        stablecoins = new address[](3);
        nfts = new address[](2);

        // stablecoins[0] = address(new Stablecoin("USDX", "USDX"));
        // stablecoins[1] = address(new Stablecoin("USDY", "USDY"));
        // stablecoins[2] = address(new Stablecoin("USDZ", "USDZ"));
        stablecoins[0] = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI
        stablecoins[1] = 0x853d955aCEf822Db058eb8505911ED77F175b99e; // FRAX
        stablecoins[2] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC
        nfts[0] = address(new BoredTurtleYachtClub());
        nfts[1] = address(new BoredSlothYachtClub());
    }

    function _deployPuzzleAndOutlet(
        address[] memory stablecoins,
        address[] memory nfts
    ) internal returns (address, address) {
        BillyTheBull puzzle = new BillyTheBull(stablecoins, nfts);
        NFTOutlet nftOutlet = puzzle.nftOutlet();
        return (address(puzzle), address(nftOutlet));
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
