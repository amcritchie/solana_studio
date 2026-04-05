# SolanaStudio Gem

Generic Solana primitives for Ruby. Extracted from Turf Monster's `app/services/solana/` layer.

## Architecture

- `Solana::Keypair` — Ed25519 key management, base58 encode/decode
- `Solana::Client` — JSON-RPC HTTP client with retry (rate limit + blockhash expiry)
- `Solana::Borsh` — Borsh binary serialization (little-endian)
- `Solana::Transaction` — Transaction builder, PDA derivation, Anchor discriminators

## API Reference

### Solana::Keypair
- `Keypair.generate` — new random Ed25519 keypair
- `Keypair.from_base58(secret_key_base58)` — load from env var
- `Keypair.from_bytes(byte_array)` — load from raw bytes
- `Keypair.from_json_file(path)` — load from Solana CLI JSON file
- `keypair.public_key` — 32-byte public key
- `keypair.address` — base58 public key string
- `keypair.sign(message)` — Ed25519 signature (64 bytes)

### Solana::Client
- `Client.new(rpc_url)` — connect to RPC (defaults to `SOLANA_RPC_URL` env or devnet)
- `client.send_rpc(method, params)` — raw JSON-RPC call with retry
- `client.get_balance(pubkey)` — SOL balance in lamports
- `client.get_token_account_balance(ata)` — SPL token balance
- `client.send_transaction(tx_base64)` — submit signed transaction
- `client.get_latest_blockhash` — recent blockhash for transactions
- Retries on rate limit (429) and expired blockhash errors

### Solana::Borsh
- `Borsh.encode_u8/u16/u32/u64(value)` — little-endian integers
- `Borsh.encode_string(str)` — length-prefixed UTF-8
- `Borsh.encode_pubkey(base58)` — 32-byte public key
- `Borsh.encode_bool(val)` — single byte
- `Borsh.encode_vec(items, type)` — length-prefixed array
- `Borsh.decode_*` — corresponding decode methods

### Solana::Transaction
- `Transaction.new` — builder pattern
- `tx.add_instruction(program_id, accounts, data)` — append instruction
- `tx.sign(keypairs, blockhash)` — sign with one or more keypairs
- `tx.serialize` — base64-encoded wire format
- `tx.serialize_partial` — for multi-signer partial signing
- `Transaction.find_pda(program_id, seeds)` — PDA derivation
- `Transaction.anchor_discriminator(name)` — SHA256-based 8-byte discriminator
- `Transaction.on_curve?(pubkey)` — check if pubkey is on Ed25519 curve

## Design Decisions

- **No Rails dependency** — pure Ruby + ed25519 gem only
- **`Solana::*` namespace** preserved from source app for zero-migration
- **No encryption** — Rails-specific `encrypt`/`from_encrypted` stays in consumer apps
- **`from_base58`** added for loading keypairs from env vars (12-factor friendly)
- **Client defaults** to `SOLANA_RPC_URL` env var or devnet

## Consumer Apps

- **Turf Monster** — keeps `Solana::Config`, `Solana::Vault`, `Solana::Reconciler`, `Solana::AuthVerifier`
- **McRitchie Studio** — can use for future Solana features

## Testing

- `ruby -Itest test/keypair_test.rb test/borsh_test.rb test/transaction_test.rb` — 9 tests
- **Keypair**: generate, base58 roundtrip, from_bytes, from_json_file, sign, address alias
- **Borsh**: encode/decode roundtrips for u8, u16, u32, u64, string, bool, pubkey, vec, bytes32
- **Transaction**: anchor discriminator (determinism, uniqueness), PDA derivation (determinism, not on curve), on_curve? check, serialization, error cases

## Repo

- GitHub: https://github.com/amcritchie/solana_studio
- Install: `gem "solana_studio", git: "https://github.com/amcritchie/solana_studio.git"`
- Version: 0.2.0
