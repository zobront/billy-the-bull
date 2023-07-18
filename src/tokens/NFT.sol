// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721 } from "@solmate/tokens/ERC721.sol";

contract NFT is ERC721 {
    constructor(address wallet, string memory name, string memory symbol) ERC721(name, symbol) {
        for (uint i = 0; i < 10; i++) {
            _mint(wallet, i);
        }
    }

    function safeMint(address to, uint256 tokenId) public {
        // needs protection for puzzle caller only
        _safeMint(to, tokenId);
    }

    function tokenURI(uint256) public pure override returns (string memory) {
        return "https://example.com";
    }
}
