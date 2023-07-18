// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721 {
    function safeMint(address to, uint256 tokenId) external;
    function balanceOf(address owner) external view returns (uint256);
    function approve(address spender, uint256 tokenId) external;
}
