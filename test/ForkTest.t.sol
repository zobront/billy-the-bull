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
    function getPuzzle(uint32) external view returns (PuzzleData memory);
    function hasSolvedPuzzle(address, uint32) external view returns (bool);
    function solve(uint32 _puzzleId, uint256 _solution) external payable;
}

contract BTBForkTest is Test {
    function testLive() public {
        vm.createSelectFork("https://mainnet.infura.io/v3/fb419f740b7e401bad5bec77d0d285a5");
        Curta curta = Curta(0x0000000006bC8D9e5e9d436217B88De704a9F307);
        IPuzzle puzzle = IPuzzle(0x9C48aE1Ae4C1a8BACcA3a52AEb22657FA0a52D3B);
        FreeWilly willy = FreeWilly(0xe5608a36489Fe45a8f08fD0c6B028801cE6B38d1);

        // vm.prank(0xf346100e892553DcEb41A927Fb668DA7B0b7C964);
        // curta.addPuzzle(address(puzzle), 54);
        // assert(puzzle == curta.getPuzzle(15).puzzle);

        bytes32 salt = 0;
        uint _start = puzzle.generate(address(this));
        uint tokenId1 = _start >> 128;
        uint tokenId2 = uint(uint128(_start));

        FlagHolder flagHolder = new FlagHolder();
        address exploiter = address(new Exploiter{salt: salt}(tokenId1, tokenId2, salt, address(puzzle), address(willy), flagHolder));

        bytes memory bytecode = abi.encodePacked(type(Exploiter).creationCode, abi.encode(tokenId1, tokenId2, salt, puzzle, willy, flagHolder));
        bytes memory magicFlag = abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode));
        flagHolder.setFlag(magicFlag);

        uint solution = uint(keccak256(flagHolder.FLAG()));
        assertEq(exploiter, address(uint160(solution)));

        curta.solve(15, solution);
        assertTrue(curta.hasSolvedPuzzle(address(this), 15));
        console.log(curta.getPuzzle(15).firstSolveTimestamp);
    }
}
