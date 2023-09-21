// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import { Script } from "forge-std/Script.sol";
import { console } from "forge-std/console.sol";
import { BillyTheBull } from "../src/BillyTheBull.sol";
import { NFTOutlet } from "../src/NFTOutlet.sol";
import { RippedJesus } from "../src/tokens/RippedJesus.sol";
import { FreeWilly } from "../src/tokens/FreeWilly.sol";

interface IPuzzle {
    function name() external pure returns (string memory);
    function generate(address _seed) external returns (uint256);
    function verify(uint256 _start, uint256 _solution) external returns (bool);
}

interface Curta {
    struct PuzzleData {
        IPuzzle puzzle;
        uint40 addedTimestamp;
        uint40 firstSolveTimestamp;
    }
    function addPuzzle(address, uint256) external;
    function puzzleId() external view returns (uint256);
    function getPuzzle(uint) external view returns (PuzzleData memory);
}

interface Authorship {
    function ownerOf(uint) external view returns (address);
}

contract DeployScript is Script {
    function run() public {
        uint256 deployerPrivateKey = vm.envUint("CURTA_PK"); // change to CURTA_PK for deployment

        // deploy tokens, puzzle, and outlet
        vm.startBroadcast(deployerPrivateKey);
        // (address[] memory stablecoins, address[] memory nfts) = _deployTokens();
        address puzzle = address(new BillyTheBull{salt: keccak256(abi.encode(vm.addr(deployerPrivateKey)))}());
        // address outlet = _deployNftOutlet(address(puzzle), stablecoins, nfts);
        // BillyTheBull(puzzle).initialize(outlet, 1000e18);
        // _logContractAddresses(stablecoins, nfts, puzzle, outlet);

        vm.stopBroadcast();
    }

    function _deployTokens() internal returns (
        address[] memory stablecoins,
        address[] memory nfts
    ){
        stablecoins = new address[](3);
        nfts = new address[](2);

        stablecoins[0] = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI
        stablecoins[1] = 0x853d955aCEf822Db058eb8505911ED77F175b99e; // FRAX
        stablecoins[2] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC
        // nfts[0] = address(new RippedJesus());
        nfts[0] = 0xe5608a36489Fe45a8f08fD0c6B028801cE6B38d1; // JESUS
        // nfts[1] = address(new FreeWilly());
        nfts[1] = 0xe5220446640A68693761e6e7429965D82db4c474; // WILLY
    }

    function _deployNftOutlet(
        address puzzle,
        address[] memory stablecoins,
        address[] memory nfts
    ) internal returns (address outlet) {
        outlet = address(new NFTOutlet(puzzle, stablecoins, nfts));
        RippedJesus(nfts[0]).initialize(outlet);
    }

    function _logContractAddresses(address[] memory _stablecoins, address[] memory _nfts, address _puzzle, address _nftOutlet) internal view {
        console.log("Contracts Deployed:");
        for (uint i = 0; i < _stablecoins.length; i++) {
            console.log("Stablecoin:", _stablecoins[i]);
        }
        for (uint i = 0; i < _nfts.length; i++) {
            console.log("NFT:", _nfts[i]);
        }
        console.log("Puzzle:", _puzzle);
        console.log("NFT Outlet:", _nftOutlet);
    }
}
