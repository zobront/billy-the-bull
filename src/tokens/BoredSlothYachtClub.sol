// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721 } from "@solmate/tokens/ERC721.sol";
import { LibString } from "@solmate/utils/LibString.sol";

contract BoredSlothYachtClub is ERC721 {
    string BASE_URL;

    constructor() ERC721("Bored Sloth Yacht Club", "BSYC") {
        BASE_URL = "http://boredsloths.com/";
    }

    // Public mint. No cost. Welcome to the Bored Sloth family.
    function mint(uint tokenId) public {
        _mint(msg.sender, tokenId);
    }

    // No transferring. When you're a Bored Sloth, you're a Bored Sloth for life.
    function transferFrom(address, address, uint256) public override {}

    // Metadata for your Sloth. Hope you like it!
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string.concat(BASE_URL, LibString.toString(tokenId));
    }

}
