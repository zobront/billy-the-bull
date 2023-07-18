// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script } from "forge-std/Script.sol";
import { BillyTheBull } from "../src/BillyTheBull.sol";
import { Protocol } from "../src/Protocol.sol";
import { Wallet } from "../src/Wallet.sol";
import { Stablecoin } from "../src/tokens/Stablecoin.sol";
import { NFT } from "../src/tokens/NFT.sol";

contract DeployScript is Script {
    function run() public {
        vm.startBroadcast();
        // _logAddresses(deployAllContracts()); // add console to do this
        deployAllContracts();
        vm.stopBroadcast();
    }

    function deployAllContracts() public returns (
        address wallet,
        address[] memory stablecoins,
        address[] memory nfts,
        address puzzle
    ) {
        wallet = _deployWallet();
        (stablecoins, nfts) = _deployTokens(wallet);
        puzzle = _deployPuzzle(wallet, stablecoins, nfts);
        Wallet(wallet).setPuzzle(puzzle);
    }

    function _deployWallet() internal returns (address wallet) {
        wallet = address(new Wallet());
    }

    function _deployTokens(address wallet) internal returns (
        address[] memory stablecoins,
        address[] memory nfts
    ){
        stablecoins = new address[](3);
        nfts = new address[](3);

        stablecoins[0] = address(new Stablecoin(wallet, "USDX", "USDX"));
        stablecoins[1] = address(new Stablecoin(wallet, "USDY", "USDY"));
        stablecoins[2] = address(new Stablecoin(wallet, "USDZ", "USDZ"));
        nfts[0] = address(new NFT(wallet, "Bored Turtles", "BTYC"));
        nfts[1] = address(new NFT(wallet, "Bored Sloths", "BSYC"));
        nfts[2] = address(new NFT(wallet, "Bored Warthogs", "BWYC"));
    }

    function _deployPuzzle(
        address wallet,
        address[] memory stablecoins,
        address[] memory nfts
    ) internal returns (address) {
        return address(new BillyTheBull(wallet, stablecoins, nfts));
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
