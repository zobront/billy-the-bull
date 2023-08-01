// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { BillyTheBull } from "../src/BillyTheBull.sol";
import { NFTOutlet } from "../src/NFTOutlet.sol";
import { FreeWilly } from "../src/tokens/FreeWilly.sol";
import { DeploymentHelpers } from "../script/DeploymentHelpers.sol";
import { Exploiter } from "./Exploiter.sol";

contract BillyTheBullSolution is DeploymentHelpers, Test {
    BillyTheBull puzzle;
    FreeWilly willy;
    address exploiter;
    bool logAddresses = false;

    function setUp() public {
        vm.createSelectFork("https://mainnet.infura.io/v3/fb419f740b7e401bad5bec77d0d285a5");
        (
            address[] memory _stablecoins,
            address[] memory _nfts,
            address _puzzle,
            address _nftOutlet
        ) = deployAllContracts();

        if (logAddresses) _logContractAddresses(_stablecoins, _nfts, _puzzle, _nftOutlet);

        puzzle = BillyTheBull(_puzzle);
        willy = FreeWilly(_nfts[1]);
    }

    function testSolution() public {
        bytes32 salt = 0;
        uint _start = puzzle.generate(address(this));
        uint tokenId1 = _start >> 128;
        uint tokenId2 = uint(uint128(_start));

        exploiter = address(new Exploiter{salt: salt}(tokenId1, tokenId2, salt, address(puzzle), address(willy)));
        uint solution = uint(keccak256(getMagicFlag(tokenId1, tokenId2, salt)));
        assertEq(exploiter, address(uint160(solution)));

        bool success = puzzle.verify(puzzle.generate(address(this)), solution);
        assertTrue(success);
    }

    function testResetPaymentToken() public {
        address tokenBefore = address(nftOutlet.paymentToken());
        assertEq(tokenBefore, DAI);

        bytes32 salt = 0;
        uint _start = puzzle.generate(address(this));
        uint tokenId1 = _start >> 128;
        uint tokenId2 = uint(uint128(_start));

        exploiter = address(new Exploiter{salt: salt}(tokenId1, tokenId2, salt, address(puzzle), address(willy)));
        uint solution = uint(keccak256(getMagicFlag(tokenId1, tokenId2, salt)));
        assertEq(exploiter, address(uint160(solution)));

        bool success = puzzle.verify(puzzle.generate(address(this)), solution);
        assertTrue(success);

        address tokenAfter = address(nftOutlet.paymentToken());
        assertEq(tokenAfter, address(willy));

        resetPaymentToken();

        address tokenAfterReset = address(nftOutlet.paymentToken());
        assertEq(tokenAfterReset, DAI);
    }

    // function testRegenerate() public {
    //     uint codeSize;
    //     address localPuzzle = address(puzzle);
    //     console.log(localPuzzle);
    //     assembly { codeSize := extcodesize(localPuzzle) }
    //     assert(codeSize > 0);

    //     puzzle.boom();
    //     assembly { codeSize := extcodesize(localPuzzle) }
    //     assertEq(codeSize, 0);

    //     address newPuzzle = manager.redeploy(1000e18);
    //     assert(newPuzzle == localPuzzle);
    //     assembly { codeSize := extcodesize(newPuzzle) }
    //     assert(codeSize > 0);
    // }

    function getMagicFlag(uint t1, uint t2, bytes32 salt) public view returns (bytes memory solution) {
        bytes memory bytecode = type(Exploiter).creationCode;
        bytecode = abi.encodePacked(bytecode, abi.encode(t1, t2, salt, puzzle, willy));
        solution = abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode));
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
