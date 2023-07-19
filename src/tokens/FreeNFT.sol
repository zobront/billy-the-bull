// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721 } from "@solmate/tokens/ERC721.sol";

contract FreeNFT is ERC721 {
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function mint(address to, uint tokenId) public {
        _mint(to, tokenId);
    }

    function tokenURI(uint256) public pure override returns (string memory) {
        return "https://example.com";
    }
}
