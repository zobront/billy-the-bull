// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { BillyTheBull } from "./BillyTheBull.sol";
import { Stablecoin } from "./tokens/Stablecoin.sol";
import { NFT } from "./tokens/NFT.sol";

contract Protocol {
    BillyTheBull immutable puzzle;
    Stablecoin public currentStablecoin;
    NFT public nft;
    mapping (address => uint) public deposits;
    mapping(address => bool) public validAssets;
    mapping(address => bool) public mintsClaimed;

    constructor(
        address[] memory _paymentTokens,
        address[] memory _nfts
    ) {
        puzzle = BillyTheBull(msg.sender);
        currentStablecoin = Stablecoin(_paymentTokens[0]);
        nft = NFT(_nfts[0]);

        for (uint256 i = 0; i < _paymentTokens.length; i++) {
            validAssets[_paymentTokens[i]] = true;
        }

        for (uint256 i = 0; i < _nfts.length; i++) {
            validAssets[_nfts[i]] = true;
        }
    }

    function _isPuzzleOwner(address _user) internal view returns (bool) {
        return puzzle.owner() == _user;
    }

    ////////////////////////
    // STABLECOIN ACTIONS //
    ////////////////////////

    function changePaymentToken(address _newStablecoin) public {
        require(_isPuzzleOwner(msg.sender), "not puzzle owner");
        require(validAssets[_newStablecoin], "not allowed asset");
        currentStablecoin = Stablecoin(_newStablecoin);
    }

    function pay(address _from, uint256 _amount) public returns (bool) {
        // require(msg.sender == address(puzzle), "only puzzle can collect");
        // red herrings? to != 0, amount < x, etc.
        // allow amount == 0
        try currentStablecoin.transferFrom(_from, address(this), _amount) returns (bool) {
            // add some unsolveable require puzzle in here to bait them
            return true;
        } catch {
            // add some unsolveable require puzzle in here to bait them
            return false;
        }
    }

    ////////////////////////
    ///// NFT ACTIONS //////
    ////////////////////////

    function mint(address _to, uint256 _tokenId) public returns (bool) {
        require(msg.sender == address(puzzle), "only puzzle can mint");
        require(!mintsClaimed[_to], "already claimed");

        try nft.safeMint(_to, _tokenId) {
            mintsClaimed[_to] = true;
            return true;
        } catch {
            return false;
        }
    }
}
