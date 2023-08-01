BEFOREHAND
- deploy puzzle via the private key held by the bot with CREATE2

BOT
- listen for self destruct on the contract
- if so, grab nftPrice from the previous block
- redeploy with CREATE2 (same salt, same sender, same init code, no constructor args)
- call initialize() with same nftoutlet but set nftPrice to same as previous block
