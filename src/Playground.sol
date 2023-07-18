// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import "./RealERC20.sol";

// contract Curta {
//     // easy to solve by fuzzing / symbolic execution
//     function negativeTricks(int a1, int a2) public returns (bool) {
//         unchecked {
//             require(a1 < 0 && a2 < 0 || a1 > 0 && a2 > 0, "same sign");
//             int new1 = -a1 + 1;
//             int new2 = -a2 + 1;
//             if (new1 == a2 && new2 == a1) return true;
//         }
//     }

//     function makeMeFail(address token) public returns (bool) {
//         (bool success, bytes memory returndata) = address(this).call(
//             abi.encodeWithSignature("tryCatch(address)", token)
//         );
//         require(!success, "should fail");
//         return true;
//     }

//     // has to pass with no return to revert!
//     function tryCatch(address _token) public returns (bool) {
//         try RealERC20(_token).transfer(address(1), 100) returns (bool) {
//             return true;
//         } catch (bytes memory reason) {
//             return false;
//         }
//     }
// }

// // immutable token in Curta contract
// // contract is Ownable, implicitly there's an owner slot
// // delegate call out
// // can overwrite storage slot to become owner
// // there's a contract that's owned by owner of Curta contract, which takes an asset (as owner, can change to USDT)
// // then change owner back before coming back
// // after: require(owner == oldOwner);
// // now we call to the other contract to a function that try catches transferring the token (maybe with some red herrings)
// // we need the call to FAIL
