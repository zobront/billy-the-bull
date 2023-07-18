// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { BillyTheBull } from "../src/BillyTheBull.sol";
import { DeployScript } from "../script/Deploy.s.sol";
import { Exploiter } from "./Exploiter.sol";

contract BillyTheBullSolution is DeployScript, Test {
    BillyTheBull puzzle;
    address exploiter;

    function setUp() public {
        (
            address _wallet,
            address[] memory _stablecoins,
            address[] memory _nfts,
            address _puzzle
        ) = deployAllContracts();
        console.log("Contracts Deployed:");
        console.log("Wallet:", _wallet);
        for (uint i = 0; i < _stablecoins.length; i++) {
            console.log("Stablecoin:", _stablecoins[i]);
        }
        for (uint i = 0; i < _nfts.length; i++) {
            console.log("NFT:", _nfts[i]);
        }
        console.log("Puzzle:", _puzzle);

        puzzle = BillyTheBull(_puzzle);
        exploiter = address(new Exploiter());
    }

    function testSolution() public {
        uint solution = 1 << 248 | 20 << 240 | uint160(exploiter);
        bool success = puzzle.verify(puzzle.generate(address(this)), solution);
        assertTrue(success);
    }

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
