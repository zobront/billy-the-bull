// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Test } from "forge-std/Test.sol";
import { console } from "forge-std/console.sol";
import { BillyTheBull } from "../src/BillyTheBull.sol";
import { NFTOutlet } from "../src/NFTOutlet.sol";
import { FreeWilly } from "../src/tokens/FreeWilly.sol";
import { DeploymentHelpers } from "./DeploymentHelpers.sol";
import { Exploiter } from "./Exploiter.sol";
import { FlagHolder } from "./FlagHolder.sol";

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
    function hasSolvedPuzzle(address, uint32) external view returns (bool);
}

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

        FlagHolder flagHolder = new FlagHolder();
        exploiter = address(new Exploiter{salt: salt}(tokenId1, tokenId2, salt, address(puzzle), address(willy), flagHolder));

        bytes memory bytecode = abi.encodePacked(type(Exploiter).creationCode, abi.encode(tokenId1, tokenId2, salt, puzzle, willy, flagHolder));
        bytes memory magicFlag = abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode));
        flagHolder.setFlag(magicFlag);

        uint solution = uint(keccak256(flagHolder.FLAG()));
        assertEq(exploiter, address(uint160(solution)));

        bool success = puzzle.verify(puzzle.generate(address(this)), solution);
        assertTrue(success);
    }

    function testFunky() public {
        bytes32 salt = 0;
        FlagHolder flagHolder = new FlagHolder{salt: salt}();
        console.log("FlagHolder: ", address(flagHolder));
        bytes memory predictedPreimageWithDeterministicDeployer = abi.encodePacked(bytes1(0xff), 0x4e59b44847b379578588920cA78FbF26c0B4956C, salt, keccak256(abi.encodePacked(type(FlagHolder).creationCode)));
        bytes memory predictedPreimageWithEOADeployer = abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(abi.encodePacked(type(FlagHolder).creationCode)));
        console.log("Deterministic: ", address(uint160(uint(keccak256(predictedPreimageWithDeterministicDeployer)))));
        console.log("EOA: ", address(uint160(uint(keccak256(predictedPreimageWithEOADeployer)))));
    }

    function testAnvilishSolution() public {
        address anvil = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;
        vm.startPrank(anvil);
        bytes32 salt = 0;
        uint _start = puzzle.generate(anvil);
        uint tokenId1 = _start >> 128;
        uint tokenId2 = uint(uint128(_start));
        address puzzleRep = 0x2C6CFc92dE181861375cA7c6E798112def6bA4a7;
        address willyRep = 0xfaE849108F2A63Abe3BaB17E21Be077d07e7a9A2;

        FlagHolder flagHolder = new FlagHolder{salt: salt}();
        bytes memory f1 = abi.encodePacked(bytes1(0xff), anvil, salt, keccak256(abi.encodePacked(type(FlagHolder).creationCode)));
        console.logBytes(type(FlagHolder).creationCode);
        console.logBytes(f1);
        console.log(address(uint160(uint(keccak256(f1)))));
        console.log("FlagHolder: ", address(flagHolder));

        // bytes memory bytecode = abi.encodePacked(type(Exploiter).creationCode, abi.encode(tokenId1, tokenId2, salt, puzzleRep, willyRep, flagHolder));
        // console.logBytes(bytecode);
        // bytes memory magicFlag = abi.encodePacked(bytes1(0xff), anvil, salt, keccak256(bytecode));
        // console.logBytes(magicFlag);

        // uint solution = uint(keccak256(flagHolder.FLAG()));
        // console.log(solution);
    }

    // function testResetPaymentToken() public {
    //     address tokenBefore = address(nftOutlet.paymentToken());
    //     assertEq(tokenBefore, DAI);

    //     bytes32 salt = 0;
    //     uint _start = puzzle.generate(address(this));
    //     uint tokenId1 = _start >> 128;
    //     uint tokenId2 = uint(uint128(_start));

    //     exploiter = address(new Exploiter{salt: salt}(tokenId1, tokenId2, salt, address(puzzle), address(willy), type(Exploiter).creationCode));
    //     uint solution = uint(keccak256(getMagicFlag(tokenId1, tokenId2, salt)));
    //     assertEq(exploiter, address(uint160(solution)));

    //     bool success = puzzle.verify(puzzle.generate(address(this)), solution);
    //     assertTrue(success);

    //     address tokenAfter = address(nftOutlet.paymentToken());
    //     assertEq(tokenAfter, address(willy));

    //     resetPaymentToken();

    //     address tokenAfterReset = address(nftOutlet.paymentToken());
    //     assertEq(tokenAfterReset, DAI);
    // }

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
        bytecode = abi.encodePacked(bytecode, abi.encode(t1, t2, salt, puzzle, willy, bytecode));
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
