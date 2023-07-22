// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { NFTOutlet } from "./NFTOutlet.sol";
import { IPuzzle } from "./interfaces/IPuzzle.sol";
import { IERC721 } from "./interfaces/IERC721.sol";

/**
You are Billy the Bull, the most infamous of NFT influencers.
Your trades move markets,
    your lambos fill Instagram timelines,
        your Twitter threads are the stuff of legends.

There's just one problem: you're broke.

With just one more trade, you'd certainly earn it all back.
But your mom is done lending you money, and there's nowhere left to turn.

A new mint has just opened up on The NFT Outlet. You _know_ it'll be a hit.
Your strategy is clear: You need 2 NFTs. Sell one. Keep the other for your collection.
If only there were a way to get them without paying...
*/
contract BillyTheBull is IPuzzle {
    address public owner;
    NFTOutlet public nftOutlet;
    uint public nftPrice;

    constructor(address[] memory _stablecoins, address[] memory _nfts) {
        owner = address(msg.sender);
        nftOutlet = new NFTOutlet(_stablecoins, _nfts);
        nftPrice = 1000e18;
    }

    function name() public pure returns (string memory) {
        return "Billy the Bull";
    }

    function generate(address _seed) public pure returns (uint256 start) {
        start = uint256(keccak256(abi.encode(_seed)));
    }

    function verify(uint _start, uint _solution) public returns (bool) {
        // decode input arguments
        uint tokenId1 = _start >> 128;
        uint tokenId2 = uint(uint128(_start));
        address wallet = address(uint160(_solution));
        IERC721 nftToBuy = nftOutlet.nftDealOfTheDay();

        // use external logic with local storage to determine the ~~magic flag~~
        bytes32 pre = keccak256(abi.encode(owner, nftOutlet, nftPrice, nftToBuy.totalSupply()));
        (, bytes memory d0) = wallet.delegatecall(abi.encodeWithSignature("getMagicFlag()"));
        bytes32 post = keccak256(abi.encode(owner, nftOutlet, nftPrice, nftToBuy.totalSupply()));
        require(pre == post, "bad boy");

        // ensure we have a unique magic flag
        bytes memory magicFlag = abi.decode(d0, (bytes));
        require(nftOutlet.magicFlagsUsed(keccak256(magicFlag)) == false, "cant be used twice");
        nftOutlet.setMagicFlagUsed(keccak256(magicFlag));

        // send payment to nft outlet for the nft & increase price for subsequent mints
        (bool s1, bytes memory d1) = address(nftOutlet).call(
            abi.encodeWithSignature("pay(address,uint256)", wallet, _incrementNFTPrice())
        );
        require(!_returnedFalse(s1, d1), "transfer must succeed");

        // mint an nft to your wallet
        (bool s2, bytes memory d2) = address(nftOutlet).call(
            abi.encodeWithSignature("mint(address,uint256)", wallet, tokenId1)
        );
        require(!_returnedFalse(s2, d2), "mint must succeed");

        // did you manage to end up with both nfts?
        require(nftToBuy.ownerOf(tokenId1) == wallet, "must own token id 1");
        require(nftToBuy.ownerOf(tokenId2) == wallet, "must own token id 2");

        // you win ... if you got the magic flag right
        return uint(keccak256(magicFlag)) == _solution;
    }

    function _returnedFalse(bool success, bytes memory data) internal pure returns (bool) {
        return success && !abi.decode(data, (bool));
    }

    function _incrementNFTPrice() public returns (uint oldPrice) {
        oldPrice = nftPrice;
        nftPrice = nftPrice + 1e18;
    }
}
