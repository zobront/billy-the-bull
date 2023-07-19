// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721 } from "@solmate/tokens/ERC721.sol";

contract NFT is ERC721 {
    uint public totalSupply;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    function safeMint(address to, uint256 tokenId) public {
        // needs protection for puzzle caller only
        _safeMint(to, tokenId);
    }

    function tokenURI(uint256) public pure override returns (string memory) {
        return "https://example.com";
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 id) internal override {
        super._mint(to, id);
        totalSupply++;
    }

    function _burn(uint256 id) internal override {
        super._burn(id);
        totalSupply--;
    }
}
