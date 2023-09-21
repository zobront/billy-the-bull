use ethers::{
    providers::{Http, Provider, Middleware, StreamExt},
    types::{Address, Filter, H256},
};
use std::{
    thread::sleep,
    time::Duration,
    process::Command,
    collections::HashSet
};


#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Connect to the local Ethereum node
    let provider = Provider::<Http>::try_from("https://mainnet.infura.io/v3/fb419f740b7e401bad5bec77d0d285a5")?;

    // Define the addresses and event signatures
    let target_address: Address = "0x9C48aE1Ae4C1a8BACcA3a52AEb22657FA0a52D3B".parse()?;
    let target_signature: H256 = ethers::utils::keccak256("OwnsBoth(address,uint256,uint256)").into();

    // Create filter for the events
    let filter = Filter::new()
        .address(target_address);

    // Create set of txs that have been used, to avoid double calls from one tx
    let mut used_txs: HashSet<H256> = HashSet::new();

    // Stream solved events so we can reset payment token
    let mut stream = provider.watch(&&filter).await?.stream();
    while let Some(log) = stream.next().await {
        println!("Event: {:?}", log);

        if used_txs.contains(&log.transaction_hash.unwrap()) {
            println!("Already used tx, skipping");
            continue;
        }
        used_txs.insert(log.transaction_hash.unwrap());

        if log.topics[0] == target_signature {
            println!("OwnsBoth event found!");

            let code_size = provider.get_code(target_address, None).await?.len();
            println!("Code size: {:?}", code_size);
            if code_size == 0 {
                // Run the redeploy script
                Command::new("bash")
                    .arg("-c")
                    .arg("forge script ../script/Redeploy.s.sol:RedeployScript --rpc-url https://mainnet.infura.io/v3/fb419f740b7e401bad5bec77d0d285a5 --broadcast")
                    .spawn()?;
                println!("Redeploy script run!");
                sleep(Duration::from_secs(30));
            }

        Command::new("bash")
            .arg("-c")
            .arg("forge script ../script/ResetPaymentToken.s.sol:ResetPaymentTokenScript --rpc-url https://mainnet.infura.io/v3/fb419f740b7e401bad5bec77d0d285a5 --broadcast")
            .spawn()?;
        println!("Reset script run!");
        }
    }

    Ok(())
}
