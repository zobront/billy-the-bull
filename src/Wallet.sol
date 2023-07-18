// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20 } from "./interfaces/IERC20.sol";
import { IERC721 } from "./interfaces/IERC721.sol";

contract Wallet {
    address puzzle;

    function setPuzzle(address _puzzle) external {
        require(puzzle == address(0), "already set");
        puzzle = _puzzle;
    }

    function setApproval(address token, address spender, uint amount) external {
        require(msg.sender == puzzle, "only puzzle");
        IERC20(token).approve(spender, amount);
    }

    function setApprovalNFT(address token, address spender, uint tokenId) external {
        require(msg.sender == puzzle, "only puzzle");
        IERC721(token).approve(spender, tokenId);
    }
}
