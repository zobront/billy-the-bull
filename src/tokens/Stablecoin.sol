// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { ERC20 } from "@solmate/tokens/ERC20.sol";

contract Stablecoin is ERC20 {
    constructor(address wallet, string memory name, string memory symbol) ERC20(name, symbol, 18) {
        _mint(wallet, 1e18);
    }
}
