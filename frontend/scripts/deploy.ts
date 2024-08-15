import "dotenv/config";

import path, { dirname } from "path";
import { fileURLToPath } from "url";
import { execSync } from "child_process";

import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { fromB64 } from "@mysten/sui/utils";
import { SuiClient } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";

const private_key = process.env.PRIVATE_KEY;
if (!private_key) {
  console.log("No private key");
  process.exit(1);
}

const deploy_script_path = dirname(fileURLToPath(import.meta.url));

const keypair = Ed25519Keypair.fromSecretKey(fromB64(private_key).slice(1));
const sui_client = new SuiClient({ url: process.env.DEVNET_URL });
// const sui_client = new SuiClient({ url: process.env.TESTNET_URL });

const contracts_path = path.join(deploy_script_path, "../../contracts");

// build packages
const { dependencies, modules } = JSON.parse(
  execSync(
    `sui move build --dump-bytecode-as-base64 --path ${contracts_path}`,
    { encoding: "utf-8" }
  )
);

// PTB
const deploy_tx = new Transaction();
const [upgrade_cap] = deploy_tx.publish({ modules, dependencies });

// upgrade_cap has to be sent to yourself
deploy_tx.transferObjects(
  [upgrade_cap],
  deploy_tx.pure.address(keypair.toSuiAddress())
);

const { objectChanges, balanceChanges } =
  await sui_client.signAndExecuteTransaction({
    signer: keypair,
    transaction: deploy_tx,
    options: {
      showBalanceChanges: true,
      showEffects: true,
      showEvents: true,
      showInput: false,
      showObjectChanges: true,
      showRawInput: false,
    },
  });
