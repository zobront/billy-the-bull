// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Protocol } from "./Protocol.sol";
import { IPuzzle } from "./interfaces/IPuzzle.sol";
import { IERC20 } from "./interfaces/IERC20.sol";
import { Wallet } from "./Wallet.sol";

/**
You are Billy the Bull, the most infamous of NFT influencers.
Your trades move markets,
    your lambos fill Instagram timelines,
        your Twitter threads are the stuff of legends.

There's just one problem: you're broke.

With just one more trade, you'd certainly earn it all back.
But your mom is done lending you money, and there's nowhere left to turn.

A new mint has just opened up. You _know_ this one will be a hit.
Your strategy is clear: You need 2 NFTs. Sell one. Keep the other for your collection.
If only there were a way to get them without paying...
*/
contract BillyTheBull is IPuzzle {
    address public owner;
    address public wallet; // could be like VAULT or something? or can it be EOA? where does it fit into story?
    address[] public stablecoins;
    address[] public nfts;

    uint NFT_PRICE = 100e18; // only 100 USD, sure to 500x

    constructor(address _wallet, address[] memory _stablecoins, address[] memory _nfts) {
        owner = address(0x69);
        wallet = _wallet;

        for (uint256 i = 0; i < _stablecoins.length; i++) {
            // fake stablecoins, all return from transferFrom, wallet holds only supply
            // do they only allow transfers via Protocol? think through it
            stablecoins.push(_stablecoins[i]);
        }
        for (uint256 i = 0; i < _nfts.length; i++) {
            // fake nfts, lots of decoys
            // make the real one non transferrable? otherwise can do it without reentrancy
            nfts.push(_nfts[i]);
        }
        // make sure wallet calls approve on all stablecoins and nfts for protocol
    }

    function name() public pure returns (string memory) {
        return "Billy the Bull";
    }

    // used as puzzle.verify(puzzle.generate(msg.sender), _solution);
    function generate(address _seed) external returns (uint256 start) {
        address protocol = address(
            new Protocol{salt: keccak256(abi.encode(_seed))}(
                address(this), stablecoins, nfts
            ));

        for (uint256 i = 0; i < stablecoins.length; i++) {
            Wallet(wallet).setApproval(stablecoins[i], protocol, type(uint256).max);
        }
        for (uint j = 0; j < 10; j++) {
            Wallet(wallet).setApprovalNFT(nfts[0], protocol, j);
        }
        return uint(uint160(protocol));
    }

    function verify(uint _start, uint _solution) public returns (bool) {
        Protocol protocol = Protocol(address(uint160(_start)));

        // split the solution into
        address impl = address(uint160(_solution));
        uint tokenId = uint8(_solution >> 240); // next 8 bits
        uint amountToPay = _solution >> 248; // first 8 bits = 0-255
        require(amountToPay >= NFT_PRICE, "insufficient payment");

        uint[] memory startingBalances = new uint[](stablecoins.length);
        for (uint256 i = 0; i < stablecoins.length; i++) {
            startingBalances[i] = IERC20(stablecoins[i]).balanceOf(wallet);
        }

        bytes32 pre = keccak256(abi.encode(owner, wallet, stablecoins, nfts));
        (bool s0,) = impl.delegatecall(abi.encodeWithSignature("doSomething(address)", address(protocol)));
        require(s0);
        bytes32 post = keccak256(abi.encode(owner, wallet, stablecoins, nfts));
        require(pre == post, "no changing state variables");

        (bool s1, bytes memory d1) = address(protocol).call(
            abi.encodeWithSignature("collectStablecoin(address,uint256)", wallet, amountToPay)
        );
        require(!_returnedFalse(s1, d1), "transfer must succeed");

        (bool s2, bytes memory d2) = address(protocol).call(
            abi.encodeWithSignature("mintNFT(address,uint256)", impl, tokenId)
        );
        require(!_returnedFalse(s2, d2), "mint must succeed");

        bool balancesChanged;
        uint afterBalance;
        for (uint256 i = 0; i < stablecoins.length; i++) {
            afterBalance = IERC20(stablecoins[i]).balanceOf(wallet);
            if (afterBalance != startingBalances[i]) {
                balancesChanged = true;
                break;
            }
        }
        require(!balancesChanged, "must not change balances");

        bool ownerOf2Nfts = protocol.nft().balanceOf(impl) == 2;
        require(ownerOf2Nfts, "must own two");

        return true;
    }

    function _returnedFalse(bool success, bytes memory data) internal pure returns (bool) {
        // check success first to avoid reverting if no data returned
        return success && !abi.decode(data, (bool));
    }
}
