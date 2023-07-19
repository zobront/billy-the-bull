// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { BillyTheBull } from "./BillyTheBull.sol";
import { Stablecoin } from "./tokens/Stablecoin.sol";
import { ERC20 } from "@solmate/tokens/ERC20.sol";
import { NFT } from "./tokens/NFT.sol";

contract NFTOutlet {
    address immutable puzzle;

    ERC20 public paymentToken;
    NFT public nftDealOfTheDay;

    mapping (address => uint) public deposits;
    mapping(address => bool) public validAssets;
    mapping(address => bool) public mintsClaimed;

    constructor(
        address[] memory _paymentTokens,
        address[] memory _nfts
    ) {
        puzzle = msg.sender;
        paymentToken = ERC20(_paymentTokens[0]);
        nftDealOfTheDay = NFT(_nfts[0]);

        for (uint256 i = 0; i < _paymentTokens.length; i++) {
            validAssets[_paymentTokens[i]] = true;
        }

        for (uint256 i = 0; i < _nfts.length; i++) {
            validAssets[_nfts[i]] = true;
        }
    }

    function _isPuzzleOwner(address _user) internal view returns (bool) {
        return BillyTheBull(puzzle).owner() == _user;
    }

    /////////////////////////
    //// PAYMENT ACTIONS ////
    /////////////////////////

    function changePaymentToken(address _newStablecoin) public {
        require(_isPuzzleOwner(msg.sender), "only puzzle owner");
        require(validAssets[_newStablecoin], "no sneaky assets");
        paymentToken = ERC20(_newStablecoin);
    }

    function pay(address _from, uint256 _amount) public returns (bool) {
        require(msg.sender == address(puzzle), "pay via puzzle");
        require(_from != address(0), "no zero address"); // decoy because if they revert with this, mint will go to addr(0)
        try paymentToken.transferFrom(_from, address(this), _amount) returns (bool) {
            // add some unsolveable require puzzle in here to bait them
            return true;
        } catch {
            // add some unsolveable require puzzle in here to bait them
            return false;
        }
    }

    /////////////////////////
    //// MINTING ACTIONS ////
    /////////////////////////

    function mint(address _to, uint256 _tokenId) public returns (bool) {
        require(msg.sender == address(puzzle), "only puzzle can mint");
        require(!mintsClaimed[_to], "already claimed");

        try nftDealOfTheDay.safeMint(_to, _tokenId) {
            mintsClaimed[_to] = true;
            return true;
        } catch {
            return false;
        }
    }
}
