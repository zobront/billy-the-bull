// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC721 } from "@solmate/tokens/ERC721.sol";
import { LibString } from "@solmate/utils/LibString.sol";

contract BoredTurtleYachtClub is ERC721 {
    address public nftOutlet;
    uint public totalSupply;
    string BASE_URL;

    constructor() ERC721("Bored Turtle Yacht Club", "BTYC") {
        BASE_URL = "http://boredtutles.com";
    }

    function initialize(address _nftOutlet) public {
        require(nftOutlet == address(0), "already initialized");
        nftOutlet = _nftOutlet;
    }

    function safeMint(address to, uint256 tokenId) public {
        require(msg.sender == nftOutlet, "only nftOutlet");
        _safeMint(to, tokenId);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return string.concat(BASE_URL, LibString.toString(tokenId));
    }

    function _mint(address to, uint256 id) internal override {
        super._mint(to, id);
        totalSupply++;
    }

    function _burn(uint256 id) internal override {
        super._burn(id);
        totalSupply--;
    }
}
