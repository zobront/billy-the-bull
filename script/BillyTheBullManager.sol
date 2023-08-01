// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { BillyTheBull } from "../src/BillyTheBull.sol";
import { NFTOutlet } from "../src/NFTOutlet.sol";
import { BoredTurtleYachtClub } from "../src/tokens/BoredTurtleYachtClub.sol";
import { BoredSlothYachtClub } from "../src/tokens/BoredSlothYachtClub.sol";

// this contract will be "owner" on puzzle
contract BillyTheBullManager {
    address immutable owner;
    address initialPaymentToken;
    address nftOutlet;

    constructor() {
        owner = msg.sender;
    }

    function deploy() public returns (
        address[] memory stablecoins,
        address[] memory nfts,
        address puzzle,
        address nftOutletReturned
    ) {
        require(owner == msg.sender, "only owner");
        (stablecoins, nfts) = _deployTokens();

        puzzle = address(new BillyTheBull{salt: keccak256(abi.encode(msg.sender))}());

        nftOutlet = _deployNftOutlet(address(puzzle), stablecoins, nfts);
        nftOutletReturned = nftOutlet;
        initialPaymentToken = stablecoins[0];

        BillyTheBull(puzzle).initialize(nftOutlet, 1000e18);
    }

    function redeploy(uint _newPrice) public {
        require(owner == msg.sender, "only owner");
        BillyTheBull puzzle = new BillyTheBull{salt: keccak256(abi.encode(msg.sender))}();
        puzzle.initialize(nftOutlet, _newPrice);
    }

    // function to reset the payment token on nftOutlet
    function resetPaymentToken() public {
        NFTOutlet(nftOutlet).changePaymentToken(initialPaymentToken);
    }


    // DEPLOYMENT

    function _deployTokens() internal returns (
        address[] memory stablecoins,
        address[] memory nfts
    ){
        stablecoins = new address[](3);
        nfts = new address[](2);

        stablecoins[0] = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI
        stablecoins[1] = 0x853d955aCEf822Db058eb8505911ED77F175b99e; // FRAX
        stablecoins[2] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC
        nfts[0] = address(new BoredTurtleYachtClub());
        nfts[1] = address(new BoredSlothYachtClub());
    }

    function _deployNftOutlet(
        address puzzle,
        address[] memory stablecoins,
        address[] memory nfts
    ) internal returns (address) {
        nftOutlet = address(new NFTOutlet(puzzle, stablecoins, nfts));
        BoredTurtleYachtClub(nfts[0]).initialize(nftOutlet);
        return nftOutlet;
    }
}
