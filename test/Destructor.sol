// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Destructor {
    function kaboom() public {
        selfdestruct(payable(address(0)));
    }
}
