// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FlagHolder {
    bytes public FLAG;

    function setFlag(bytes memory _flag) external {
        FLAG = _flag;
    }
}
