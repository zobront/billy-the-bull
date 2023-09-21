Billy The Bull is entering Phase 2.

That means it's time for me to share a walkthrough, and time for you to get to work solving it (48 hours left).

The goal of the puzzle: mint two rare Ripped Jesus NFTs without paying for them.

Sounds easy, but there are many challenges in your way...

***

CHALLENGE 1: GET YOUR SOLUTION'S PREIMAGE

Looking at the code, it's clear that our solution is the address of a contract we've deployed to solve the challenge.

Because Curta requires solution to be in `uint256` form, it's decoded into the address that's used.

***

This might make you think you can just pass `uint256(solution)` as the solution.

But the final step of the puzzle is to check that the "magic flag" we returned is the preimage of our solution.

If we use `uint256(solution)`, there is no reasonable way to know the preimage.

***

Fortunately, since we're decoding the solution as `address(uint160(_solution))`, we can pass a full 32 byte word as the solution.

If we understand how addresses are created on the EVM, this is a value we can find the preimage for:

- IF CREATE: keccak256(x), where x is address of the creator + nonce of the creator. Shorten to 20 bytes.
- IF CREATE2: keccak256(x), where x is 0xff + address of the creator + salt + init code. Shorten to 20 bytes.

In either case, we can use `x` as the magic flag, and pass the full 32 byte word as our solution.

***

CHALLENGE 2: GET BOTH NFTs BY CALLING MINT ONCE

We must mint two separate token IDs in order to pass the challenge, but we only call `mint()` on tokenId1.

If we look at the implementation of NFTOutlet.sol, we can see that it uses `safeMint()`.

***

Looking at the `safeMint()` implementation, we can see that it first mints, and then performs the check.

This is a perfect setup for reentrancy, because we gain control flow after we've gotten our first NFT.

***

When we reenter the second time, we already have token ID 1.

If we use token ID 2 and another value, we'll still fail the check at the end of the inner loop that we have both tokens.

But if we flip the order of the two token IDs, then we'll mind token ID 2, and by the time the reentered function call gets to the ownership check, we will hold both NFTs and it will pass.

***

CHALLENGE 3: WE CAN'T REUSE THE FLAG WHEN REENTERING

We are forced to use the same solution when we reenter by the `noTampering` modifier.

But we can't reuse the magic flag. The registry of used magic flags in the NFT Outlet cannot be edited.

***

This should be impossible. We've used the preimage for this address and have to use the same address again. There is no other preimage.

And, it is impossible. There's no way to do it.

But, fortunately, you don't have to.

***

Many Curta players assume that `verify()` needs to pass.

But this isn't required. It just returns a boolean that is used by Curta.

This causes a revert when going through the main Curta contract, but not if `verify()` is called directly on the puzzle.

This allows us to simply use a magic flag that doesn't pass, causing the inner call to return false.

***

CHALLENGE 4: THE NFT COSTS 1000 DAI

No, the trick is not to simply send me $1000.

What you'll notice if you read the contract carefully is that the `_returnedFalse()` check only reverts if the call returns the false value. If the call reverts, everything will move along normally.

This is great, except... how can you make it revert?

***

Reading the function, you may think it's impossible.

There are three require statements, all of which cannot be triggered:
1) from == address(0) => this is the wallet address, so if it's address(0), it can't hold the code needed for the steps below (and it's impossible to know the preimage)
2) keccak256(amount) = 0x420badbabe => you would have to know the preimage of the hash
3) uint(uint32(amount)) <= 4294967295 => if we lower to 32 bits, we can't get a value higher than max uint32

***

But there is one other way to make the function revert.

Try catch statements will revert if they expect a return value and none is given: https://blog.theredguild.org/catch-me-if-you-can/

So if we can make the `transferFrom()` function give no return value, it'll revert and everything can pass.

But how is this possible? All the ERC20 tokens that are valid assets return a bool from `transferFrom()`.

***

CHALLENGE 5: TRANSFER FROM WITH NO RETURN VALUE

If we look at the ERC20 spec, we can see that `transferFrom()` must return a bool.

Some ERC20s don't, but the valid assets in NFT Outlet all conform to the spec.

But what about `transferFrom()` on ERC721s? The signature matches exactly, but it doesn't return anything...

***

Since all the ERC20s and ERC721s are stored in the same `validAssets` mapping, it means that an NFT can be subbed in as the paymentToken.

Since they have a `transferFrom()` function with the same signature, if this function is called (and doesn't revert), it'll return nothing.

***

Note that the NFT transfer has to succeed for this to happen, otherwise it'll revert on the call and be caught by the try catch block.

So we need to own the NFT ID corresponding with the "price" of the payment token that should be sent.

***

Fortunately, you can dig up the other valid assets by finding the constructor arguments from when NFT Outlet was deployed.

If you do, you'll find that the Free Willy NFT contract is verified on Etherscan and has free open mints.

***

So you can mint the NFT ID you need (plus the incremented version that is 1e18 higher for when you need to do the same thing while reentering), `transferFrom()` will succeed, the NFT Outlet function will revert because there's no return value, and the puzzle will keep moving.

***

CHALLENGE 6: CHANGING PAYMENT TOKEN TO THE NFT

All this assumes we can change the payment token. But it can only be changed by the owner of the puzzle, which is an address I own.

The challenge begins with a very suspicious delegate call, but all the storage variables are checked after the call to ensure they match with the values before. Nothing can be changed.

***

However, there's nothing stopping you from changing them midflight.

This is loosely based on issue 3.2.6 that @RustyRabbit and I found in Sablier: https://github.com/sablier-labs/audits/blob/main/v2-periphery/cantina-2023-07-11.pdf

With this ability, we can change the owner of the contract to ourselves, call `changePaymentToken()` to change it to the Free Willy NFT, and then change the owner back to the original so the postflight check passes.

***

This is the final piece of the puzzle needed to solve the challenge.

I thought it would definitely take 4-6 hours. @lj1nu managed to solve all of this and code it up in 1:52:00. Truly impressive.

Even with everything in this thread, this is a fun and challenging one to write up a solution for. There are 48 hours left to do that, then I'll release a full coded solution.

🫡
