// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { BillyTheBull } from "./BillyTheBull.sol";
import { IERC20 } from "./interfaces/IERC20.sol";
import { IERC721 } from "./interfaces/IERC721.sol";

contract Protocol {
    BillyTheBull immutable puzzle;
    IERC20 public stablecoin;
    IERC721 public nft;
    mapping(address => bool) public allowedAssets;
    mapping(address => bool) public mintsClaimed;

    constructor(address _puzzle, address[] memory _stablecoins, address[] memory _nfts) {
        stablecoin = IERC20(_stablecoins[0]);
        nft = IERC721(_nfts[0]);
        puzzle = BillyTheBull(_puzzle);

        for (uint256 i = 0; i < _stablecoins.length; i++) {
            allowedAssets[_stablecoins[i]] = true;
        }

        for (uint256 i = 0; i < _nfts.length; i++) {
            allowedAssets[_nfts[i]] = true;
        }
    }

    function _isPuzzleOwner(address _user) internal view returns (bool) {
        return puzzle.owner() == _user;
    }

    // STABLECOIN ACTIONS //

    function changeStablecoin(address _newStablecoin) public {
        require(_isPuzzleOwner(msg.sender), "not puzzle owner");
        require(allowedAssets[_newStablecoin], "not allowed asset");
        stablecoin = IERC20(_newStablecoin);
    }

    function collectStablecoin(address _from, uint256 _amount) public returns (bool) {
        require(msg.sender == address(puzzle), "only puzzle can collect");
        // red herrings? to != 0, amount < x, etc.
        // allow amount == 0
        try stablecoin.transferFrom(_from, address(this), _amount) returns (bool) {
            // add some unsolveable require puzzle in here to bait them
            return true;
        } catch {
            // add some unsolveable require puzzle in here to bait them
            return false;
        }
    }

    // NFT ACTIONS //

    function changeNFT(address _newNFT) public {
        require(_isPuzzleOwner(msg.sender), "not puzzle owner");
        require(false); // something that makes it impossible... or not? just let them
        require(allowedAssets[_newNFT], "not allowed asset");
        nft = IERC721(_newNFT);
    }

    function mintNFT(address _to, uint256 _tokenId) public returns (bool) {
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
