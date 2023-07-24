get ready @chainlight_io @junorouse

...

if nobody has solved it:
- talk a lot of shit :)
- get more security ppl in who don't usually do curta
- clues:
    - past audit reports hold some answers (hats, etc)
    - try catch article


***

blah blah intro


To solve this puzzle requires many breakthroughs, and the easiest way to approach them is to start with the end goal.

Let's start with the final outcome, and work backwards to see how we can get there.


CHALLENGE 1: We need to return a magic flag that is the preimage of our solution.

We see that the solution is decoded into the wallet address that's used for the challenge.

This might make you think you can just pass uint256(address) as the solution. But if we use this value, there is no way to know the preimage.

Fortunately, since we're decoding the solution as address(uint160(_solution)), we can pass a full 32 byte word as the solution. And if we understand how addresses are created on the EVM, we can know the preimage for this value.

Addresses can be selected on the EVM in one of two ways:

1) CREATE: Hash X, where X is the address of the creator and the nonce of the creator. Shorten to 20 bytes.

2) CREATE2: Hash X, where X is the address of the creator, the salt, and the init code. Shorten to 20 bytes.

In either case, we can use X as the magic flag, and pass the full 32 byte word as our solution.

In my solution, I used CREATE2...




CHALLENGE 2: We need both NFTs immediately after minting just 1.

We must mint two separate token IDs in order to pass the challenge, but only tokenId1 is minted.

If we look at the implementation of NFTOutlet.sol, we can see that it uses `safeMint()`.

Looking at the safeMint() implementation, we can see that it first mints, and then performs the check.

This is a perfect setup for reentrancy, because we gain control flow after we've gotten the NFT.

When we reenter the second time, we already have token ID 1.

If we flip the two token IDs around the second time, we'll then mint the original token ID 2, and by the time the reentered pass gets to the check, we will hold both NFTs and it will pass.


CHALLENGE 3: We need to use the same solution when reentering, but can't reuse it.

This should be impossible. We've used the preimage for this address and have to use the same address again.

And, it is impossible. There's no way to do it, and no way to get around it.

But, fortunately, you don't have to.

The assumption is that verify() needs to pass.

But this isn't required. It just returns a boolean that is used by Curta (and reverts when going through the main Curta contract).

But if we reenter into the puzzle directly, we can use a magic flag that doesn't pass, and it will simply return false.


CHALLENGE 4: The cost of the NFT is $1000+ USD, paid in a real stablecoin.

No, the trick is not to simply send me $1000.

What you'll notice if you read the contract carefully is that the _returnedFalse() check only happens if it returns the false value. If the call reverts, everything will move along normally.

This is great, except... how can you make it revert?

If you read the function, you may think it's impossible.

There are three require statements, and all are impossible to trigger:
1) from == address(0) => this is the wallet address, so if it's address(0), it can't hold the code needed for any of this, and it's impossible to know the preimage
2) keccak256(amount) = 0x420badbabe => you would have to know the preimage of the hash
3) uint(uint32(amount)) <= 4294967295 => if we lower to 32 bits, we can't get a value higher than max uint32

But there is one way to make the function revert.

Try catch statements will revert if they expect a return value and none is given.

So if we can make the transferFrom function have no return value, it'll revert and everything can pass.

But how is this possible? All the ERC20 tokens that are valid assets return something from transferFrom.


CHALLENGE 5: How can we get transferFrom to return nothing?

If we look at the ERC20 spec, we can see that transferFrom must return a bool.

Some ERC20s don't, but the valid assets in NFT Outlet all conform to the spec.

But what about transferFrom on ERC721s? That doesn't return anything.

Since all the assets are stored in the validAssets mapping, it means that NFTs can be subbed in as paymentTokens.

Since they have a transferFrom function with the same signature, if it's used, it'll revert.

Note that the NFT transfer has to succeed for this to happen (otherwise it'll revert on the call and be caught by the try catch block).

So we need to own the NFT ID corresponding with the "price" of the payment token that should be sent.

Fortunately, one of the NFT contracts has free open mints. So you can mint the NFT ID you need (plus the incremented version that is 1e18 higher for when you need to do the same thing while reentering), the transferFrom will succeed, the NFT Outlet function will revert because there's no return value, and the puzzle will keep moving.


CHALLENGE 6: But how can you change the payment token to the NFT?

The challenge begins with a very suspicious delegate call. But all the storage variables are checked after the call to ensure they match with the values before. Nothing can be changed.

However, there's nothing stopping you from changing them midflight!

This allows you to change the owner of the contract to yourself, then call `changePaymentToken()` to change it to the NFT, and then change the owner back to the original so the postflight check passes.

This is the final piece of the puzzle, and allows you to pass the challenge.


***

To summarize the attack:
- Deploy an attacker contract and save the preimage as magic flag
- Upon deployment, mint yourself free NFTs with indexes corresponding to the current NFT price and price + 1e18
- When `getMagicFlag()` is called on the attacker contract when in the outer loop, use storage collision to set yourself as owner of the puzzle, change the payment token of NFT Outlet to the free NFT, and change the owner back. When in the inner loop, simply return a random unused byte string (because the magic flag doesn't matter).
- When safeMint() is called on the NFT, use the onERC721Received check to call `verify()` on the puzzle again with the same solution, but with the two token IDs flipped in order

You can find my coded solution at github.com/sdfljksflk
