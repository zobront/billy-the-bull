// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { BillyTheBull } from "../src/BillyTheBull.sol";
import { NFTOutlet } from "../src/NFTOutlet.sol";
import { RippedJesus } from "../src/tokens/RippedJesus.sol";
import { FreeWilly } from "../src/tokens/FreeWilly.sol";

contract DeploymentHelpers {
    NFTOutlet nftOutlet;
    address DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    function deployAllContracts() public returns (
        address[] memory stablecoins,
        address[] memory nfts,
        address puzzle,
        address outlet
    ) {
        (stablecoins, nfts) = _deployTokens();
        puzzle = address(new BillyTheBull{salt: keccak256(abi.encode(msg.sender))}());
        outlet = _deployNftOutlet(address(puzzle), stablecoins, nfts);
        nftOutlet = NFTOutlet(outlet);
        BillyTheBull(puzzle).initialize(outlet, 1000e18);
    }

    function redeployPuzzle(address _nftOutlet, uint _nftPrice) public {
        address puzzle = address(new BillyTheBull{salt: keccak256(abi.encode(msg.sender))}());
        BillyTheBull(puzzle).initialize(_nftOutlet, _nftPrice);
    }

    function _deployTokens() internal returns (
        address[] memory stablecoins,
        address[] memory nfts
    ){
        stablecoins = new address[](3);
        nfts = new address[](2);

        stablecoins[0] = 0x6B175474E89094C44Da98b954EedeAC495271d0F; // DAI
        stablecoins[1] = 0x853d955aCEf822Db058eb8505911ED77F175b99e; // FRAX
        stablecoins[2] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // USDC
        nfts[0] = address(new RippedJesus());
        nfts[1] = address(new FreeWilly());
    }

    function _deployNftOutlet(
        address puzzle,
        address[] memory stablecoins,
        address[] memory nfts
    ) internal returns (address outlet) {
        outlet = address(new NFTOutlet(puzzle, stablecoins, nfts));
        RippedJesus(nfts[0]).initialize(outlet);
    }

    function resetPaymentToken() public {
        nftOutlet.changePaymentToken(DAI);
    }
}
