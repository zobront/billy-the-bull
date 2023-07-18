// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "forge-std/Test.sol";
// import "../src/Curta.sol";
// import "../src/RealERC20.sol";
// import "../src/FakeERC20.sol";

// contract Caller {
//     address public owner;

//     function delCall(address _token) public {
//         _token.delegatecall("");
//     }
// }

// contract Callee {
//     address public owner;

//     fallback() external {
//         owner = address(this);
//     }
// }

// contract DelCallTest is Test {
//     Caller public caller;
//     Callee public callee;

//     function setUp() public {
//         caller = new Caller();
//         callee = new Callee();
//     }

//     function testDelCall() public {
//         assertEq(caller.owner(), address(0));
//         caller.delCall(address(callee));
//         assertEq(caller.owner(), address(caller));
//     }
// }

// contract CurtaTest is Test {
//     Curta public curta;
//     RealERC20 public realErc20;
//     FakeERC20 public fakeErc20;

//     // function setUp() public {
//     //     curta = new Curta();
//     //     realErc20 = new RealERC20("ERC20", "ERC20", 18);
//     //     fakeErc20 = new FakeERC20();
//     // }

//     function testTryCatch() public {
//         bool first = curta.tryCatch(address(realErc20));
//         assertEq(first, false);

//         bool second = curta.makeMeFail(address(fakeErc20));
//         assertEq(second, true);
//     }

//     function testWithUSDT() public {
//         vm.createSelectFork("https://mainnet.infura.io/v3/fb419f740b7e401bad5bec77d0d285a5");
//         curta = new Curta();
//         address usdt = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
//         deal(usdt, address(curta), 100);
//         curta.makeMeFail(usdt);
//     }

//     function testNegativeTricks(int a, int b) public {
//         vm.assume(a < 0 && b < 0 || a > 0 && b > 0);
//         bool success = curta.negativeTricks(a, b);
//         assert(!success);
//     }
// }
