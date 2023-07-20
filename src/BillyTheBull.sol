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

A new mint has just opened up on The NFT Outlet. It's cheap, and you _know_ it'll be a hit.
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
        nftPrice = 1e18;
    }

    function name() public pure returns (string memory) {
        return "Billy the Bull";
    }

    // used as puzzle.verify(puzzle.generate(msg.sender), _solution);
    function generate(address _seed) public pure returns (uint256 start) {
        start = uint256(keccak256(abi.encode(_seed)));
    }

    function verify(uint _start, uint _solution) public returns (bool) {
        // decode input arguments
        uint tokenId1 = _start >> 128;
        uint tokenId2 = uint(uint128(_start));
        address wallet = address(uint160(_solution));
        IERC721 nftToBuy = nftOutlet.nftDealOfTheDay();

        // use local storage to determine the ~~magic token id~~
        // @todo NEED NEW EXCUSE FOR THIS!
        bytes32 pre = keccak256(abi.encode(owner, nftOutlet, nftPrice, nftToBuy.totalSupply()));
        (bool s0, bytes memory d0) = wallet.delegatecall(abi.encodeWithSignature("getMagicTokenId()"));
        bytes32 post = keccak256(abi.encode(owner, nftOutlet, nftPrice, nftToBuy.totalSupply()));
        require(s0 && pre == post, "bad boy");
        uint magicTokenId = abi.decode(d0, (uint));

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

        // you win
        return true;
    }

    function _returnedFalse(bool success, bytes memory data) internal pure returns (bool) {
        // check success first to avoid reverting if no data returned
        return success && !abi.decode(data, (bool));
    }

    function _incrementNFTPrice() public returns (uint oldPrice) {
        oldPrice = nftPrice;
        nftPrice = nftPrice + 1e18;
    }
}
